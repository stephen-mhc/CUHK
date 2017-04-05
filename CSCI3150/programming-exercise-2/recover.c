#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#define RESERVED_SIZE B.BPB_RsvdSecCnt * B.BPB_BytsPerSec
#define DATA_AREA_START (B.BPB_RsvdSecCnt + B.BPB_NumFATs * B.BPB_FATSz32) * B.BPB_BytsPerSec
#define CLUSTER_SIZE B.BPB_SecPerClus * B.BPB_BytsPerSec

struct BootEntry {
	unsigned char BS_jmpBoot[3];
	unsigned char BS_OEMName[8];
	unsigned short BPB_BytsPerSec;
	unsigned char BPB_SecPerClus;
	unsigned short BPB_RsvdSecCnt;
	unsigned char BPB_NumFATs;
	unsigned short BPB_RootEntCnt;
	unsigned short BPB_TotSec16;
	unsigned char BPB_Media;
	unsigned short BPB_FATSz16;
	unsigned short BPB_SecPerTrk;
	unsigned short BPB_NumHeads;
	unsigned int BPB_HiddSec;
	unsigned int BPB_TotSec32;
	unsigned int BPB_FATSz32;
	unsigned short BPB_ExtFlags;
	unsigned short BPB_FSVer;
	unsigned int BPB_RootClus;
	unsigned short BPB_FSInfo;
	unsigned short BPB_BkBootSec;
	unsigned char BPB_Reserved[12];
	unsigned char BS_DrvNum;
	unsigned char BS_Reserved1;
	unsigned char BS_BootSig;
	unsigned int BS_VolID;
	unsigned char BS_VolLab[11];
	unsigned char BS_FilSysType[8];
};

struct DirEntry{
	unsigned char DIR_Name[11];
	unsigned char DIR_Attr;
	unsigned char DIR_NTRes;
	unsigned char DIR_CrtTimeTenth;
	unsigned short DIR_CrtTime;
	unsigned short DIR_CrtDate;
	unsigned short DIR_LstAccDate;
	unsigned short DIR_FstClusHI;
	unsigned short DIR_WrtTime;
	unsigned short DIR_WrtDate;
	unsigned short DIR_FstClusLO;
	unsigned int DIR_FileSize;
};

struct BootEntry B;
int fd;
unsigned int deleted_file_size;

void print_Usage(char *argv){
	printf("Usage: %s -d [device filename] [other arguments]\n", argv);
	printf("-l target            List the target directory\n");
	printf("-r target -o dest    Recover the target pathname\n");
	exit(0);
}

void replace_Space(unsigned char *Dir_Name){
	int i = 10;
	if (Dir_Name[i] != ' ')
		return; 
	while (Dir_Name[i] == ' '){
		i--;
	}
	i++;
	Dir_Name[i] = '\0';

	return;
}

void read_Boot_Sec(char *fat32_disk){
	pread(fd, &B.BPB_BytsPerSec, 2, 11);
	pread(fd, &B.BPB_SecPerClus, 1, 13);
	pread(fd, &B.BPB_RsvdSecCnt, 2, 14);
	pread(fd, &B.BPB_NumFATs, 1, 16);
	pread(fd, &B.BPB_TotSec16, 2, 19);
	pread(fd, &B.BPB_TotSec32, 4, 32);
	pread(fd, &B.BPB_FATSz32, 4, 36);
	pread(fd, &B.BPB_RootClus, 4, 44);
	return;
}

unsigned int lookup_FAT(unsigned int cluster){
	unsigned int next_cluster;
	pread(fd, &next_cluster, sizeof(next_cluster), RESERVED_SIZE + cluster * 4);
	return next_cluster;
}

unsigned int find_Dir(unsigned char *dir, unsigned int cluster){
	int i;
	struct DirEntry D;
	unsigned int target_cluster;
	for (i = 0; i >= 0; i++){
		if (i > CLUSTER_SIZE / 32 - 1){
			cluster = lookup_FAT(cluster);
			if (cluster >= 0x0ffffff8){
				break;
			}
			else {
				target_cluster = find_Dir(dir, cluster);
				break;
			}
		}
		pread(fd, &D, sizeof(D), DATA_AREA_START + (cluster - B.BPB_RootClus) * CLUSTER_SIZE + i * sizeof(D));
		if (D.DIR_Attr == 0x00 || D.DIR_Attr == 0x0f || D.DIR_Attr != 0x10){}
		else if (D.DIR_Attr == 0x10){
			replace_Space(D.DIR_Name);
			if (!strcmp(dir, D.DIR_Name)){
				target_cluster = D.DIR_FstClusHI * 65536 + D.DIR_FstClusLO;
				break;
			}
		}
	}
	return target_cluster;
}

void print_Dir(unsigned int target_cluster){
	struct DirEntry D;
	unsigned char dirEntryName[11];
	unsigned int size;
	unsigned int start_cluster;
	int count = 0;
	int i;
	for (i = 0; i >= 0; i++){
		if (i > CLUSTER_SIZE / 32 - 1){
			target_cluster = lookup_FAT(target_cluster);
			if (target_cluster >= 0x0ffffff8){
				break;
			}
			else {
				print_Dir(target_cluster);
				break;
			}
		}
		pread(fd, &D, sizeof(D), DATA_AREA_START + (target_cluster - B.BPB_RootClus) * CLUSTER_SIZE + i * sizeof(D));
		if (D.DIR_Attr == 0x0f){}
		else if (D.DIR_Attr == 0x20){
			count++;
			strcpy(dirEntryName, D.DIR_Name);
//			replace_Space(dirEntryName);
			size = D.DIR_FileSize;
			start_cluster = D.DIR_FstClusHI * 65536 + D.DIR_FstClusLO;
			printf("%d, ", count);
			int j = 0;
			if (D.DIR_Name[0] == 0xe5){
				printf("?");
				j = 1;
			}
			while (dirEntryName[j] != ' ' && j < 8)
				printf("%c", dirEntryName[j++]);
			if (dirEntryName[8] != ' ')
				printf(".");
			j = 8;
			while (dirEntryName[j] != ' ' && j < 11)
				printf("%c", dirEntryName[j++]);
			printf(", %d, %d\n", size, start_cluster);
		}
		else if (D.DIR_Attr == 0x10){
			count++;
			strcpy(dirEntryName, D.DIR_Name);
			replace_Space(dirEntryName);
			size = D.DIR_FileSize;
			start_cluster = D.DIR_FstClusHI * 65536 + D.DIR_FstClusLO;
			printf("%d, %s/, %d, %d\n", count, dirEntryName, size, start_cluster);
		}
		else if (D.DIR_Attr == 0x00)
			break;
	}
	return;
}

void list_Dir(unsigned char *target_path){
	unsigned int target_cluster = 0;
	unsigned char *dir;
	dir = strtok(target_path, "/");
	if (dir == NULL){
		target_cluster = B.BPB_RootClus;
		print_Dir(target_cluster);
		return;
	}
	target_cluster = B.BPB_RootClus;
	while (dir != NULL){
		target_cluster = find_Dir(dir, target_cluster);
		dir = strtok(NULL, "/");
	}
	print_Dir(target_cluster);
	return;
}

void convert_Filename(unsigned char *filename, unsigned char *dir_filename){
	int has_dot = 0;
	int k;
	for (k = 0; k < strlen(filename); k++){
		if (filename[k] == '.'){
			has_dot = 1;
			break;
		}
	}
	if (!has_dot){
		int i = 0;
		while (filename[i] != '\0'){
			dir_filename[i] = filename[i];
			i++;
		}
		while (i < 11)
			dir_filename[i++] = ' ';
		dir_filename[11] = '\0';
	}
	else {
		int i = 0, j = 0;
		while (filename[i] != '.'){
			dir_filename[i] = filename[i];
			i++;
		}
		j = i + 1;
		while (i < 8)
			dir_filename[i++] = ' ';
		while (filename[j] != '\0'){
			dir_filename[i] = filename[j];
			i++; j++;
		}
		while (i < 11)
			dir_filename[i++] = ' ';
		dir_filename[11] = '\0';
	}
	dir_filename[0] = 0xe5;

	return;
}

unsigned int locate_File(unsigned char *dir_filename, unsigned int target_cluster){
	struct DirEntry D;
	unsigned int start_cluster;
	int file_found = 0;
	int i;
	for (i = 0; i >= 0; i++){
		if (i > CLUSTER_SIZE / 32 - 1){
			target_cluster = lookup_FAT(target_cluster);
			if (target_cluster >= 0x0ffffff8)
				break;
			else {
				start_cluster = locate_File(dir_filename, target_cluster);
				break;
			}
		}
		pread(fd, &D, sizeof(D), DATA_AREA_START + (target_cluster - B.BPB_RootClus) * CLUSTER_SIZE + i * sizeof(D));
		if (D.DIR_Attr == 0x00)
			break;
		int m = 0;
		int same = 1;
		while (m < 11){
			if (D.DIR_Name[m] != dir_filename[m]){
				same = 0;
				break;
			}
			m++;
		}
		if (same == 1){
			file_found = 1;
			deleted_file_size = D.DIR_FileSize;
			break;
		}
	}
	if (!file_found)
		start_cluster = 0;
	else if (deleted_file_size == 0)
		start_cluster = 1;
	else start_cluster = D.DIR_FstClusHI * 65536 + D.DIR_FstClusLO;
	return start_cluster;
}

int fetch_Content(unsigned int target_cluster, unsigned char *output_file){
	FILE *f = fopen(output_file, "w");
	if (f == NULL)
		return -1;
	else if (lookup_FAT(target_cluster) != 0x00)
		return 0;
	else {
		char buf[CLUSTER_SIZE];
		pread(fd, buf, deleted_file_size, DATA_AREA_START + (target_cluster - B.BPB_RootClus) * CLUSTER_SIZE);
		buf[deleted_file_size] = '\0';
		fprintf(f, "%s", buf);
		fclose(f);
		return 1;
	}
}

void recover_File(unsigned char *target_path, unsigned char *output_file){
	unsigned int dir_cluster = 0;
	unsigned int file_cluster = 0;
	unsigned char target_path_complete[1024];
	strcpy(target_path_complete, target_path);
	unsigned char filename[12];
	unsigned char dir_filename[11];
	unsigned char *ptr = &target_path[strlen(target_path) - 1];
	while (*ptr != '/')
		ptr--;
	ptr++;
	strcpy(filename, ptr);
	ptr--;
	*ptr = '\0';

	unsigned char *dir = strtok(target_path, "/");
	if (dir == NULL)
		dir_cluster = B.BPB_RootClus;
	else {
		dir_cluster = B.BPB_RootClus;
		while (dir != NULL){
			dir_cluster = find_Dir(dir, dir_cluster);
			dir = strtok(NULL, "/");
		}
	}

	convert_Filename(filename, dir_filename);

	file_cluster = locate_File(dir_filename, dir_cluster);

	if (file_cluster == 0)
		printf("%s: error - file not found\n", target_path_complete);
	else if (file_cluster == 1){
		FILE *f = fopen(output_file, "w");
		if (f == NULL){
			printf("%s: failed to open\n", output_file);
			return;
		}
		else if (f != NULL){
			fclose(f);
			printf("%s: recovered\n", target_path_complete);
		}
	}
	else {
		int result = fetch_Content(file_cluster, output_file);
		if (result == -1)
			printf("%s: failed to open\n", output_file);
		else if (result == 0)
			printf("%s: error - fail to recover\n", target_path_complete);
		else if (result == 1)
			printf("%s: recovered\n", target_path_complete);
	}

	return;
}

int main(int argc, char *argv[]){
	char opt;
	char *fat32_disk, *l_target, *r_target, *o_dest;
	int dflag = 0, lflag = 0, rflag = 0, oflag = 0;
	while ((opt = getopt(argc, argv, "d:l:r:o:")) != -1){
		switch (opt){
		case 'd':
			dflag = 1;
			fat32_disk = optarg;
			break;
		case 'l':
			if (!dflag || rflag)
				print_Usage(argv[0]);
			lflag = 1;
			l_target = optarg;
			break;
		case 'r':
			if (!dflag || lflag)
				print_Usage(argv[0]);
			rflag = 1;
			r_target = optarg;
			break;
		case 'o':
			if (!dflag || lflag || !rflag)
				print_Usage(argv[0]);
			oflag = 1;
			o_dest = optarg;
			break;
		default:
			print_Usage(argv[0]);
		}
	}
	if (!dflag || (!lflag && !rflag) || (rflag && !oflag))
		print_Usage(argv[0]);

	fd = open(fat32_disk, O_RDONLY);

	read_Boot_Sec(fat32_disk);

	if (lflag){
		list_Dir(l_target);
	}
	else if (rflag)
		recover_File(r_target, o_dest);

	close(fd);

	return 0;
}
