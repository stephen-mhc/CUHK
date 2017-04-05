// CSCI3180 Principles of Programming Languages
// ---Declaration---
// I declare that the assignment here submitted is original except for source material explicitly
//acknowledged. I also acknowledge that I am aware of University policy and regulations on honesty
// in academic work, and of the disciplinary guidelines and procedures applicable to breaches of
// such policy and regulations, as contained in the website
// http://www.cuhk.edu.hk/policy/academichonesty/
// Assignment 3
// Name: Stephen CHEONG Man Hoi
// Student ID: 1155043317
// Email Addr: stephencheong623@yahoo.com.hk

#include <stdio.h>
#include <string.h>

int creditLimit = 5000;

int payment(char * name, int balance, int payAmt) {
	printf("\n... Consumption payment (Luk Card) ...\n");

	int currentLimit = creditLimit - balance;
	if (currentLimit < payAmt){
		printf("You have exceeded your credit limit!\n");
		return -1;
	}

	currentLimit -= payAmt;

	balance += payAmt;

	printf("You have just payed a [HKD %d] consumption!\n", payAmt);
	printf("Now your remaining credit limit is [HKD %d]\n", currentLimit);

	return balance;
}

int repayment(char * name, int balance, int repayAmt) {
	printf("\n... Repaying debts ...\n");
	printf("Thank you, %s! ", name);

	balance -= repayAmt;

	printf("You have just repayed [HKD %d]!\n", repayAmt);

	int currentLimit = creditLimit - balance;
	printf("Now your remaining credit limit is [HKD %d].\n", currentLimit);

	return balance;
}

void regularClient(char * name, int balance, int repayAmt, int payAmt) {
	// repaying debts
	balance = repayment(name , balance, repayAmt);

	if (balance >= 0)
		printf("[Current card balance: HKD %d]\n", balance);
	else
		printf("ERROR! You are trying to repay more than your debt amount!\n");

	// paying for consumption
	balance = payment(name, balance, payAmt);

	if (balance >= 0)
		printf("[Current card balance: HKD %d]\n", balance);
	else
		printf("ERROR! You are trying to pay beyond your credit limit!\n");
}

void premierClient(char * name, int balance, int repayAmt, int payAmt) {
	int creditLimit = 10000;

	printf("Dear Premier client %s, you have a credit limit of [HKD %d]! Enjoy!\n", name, creditLimit);

	regularClient(name, balance, repayAmt, payAmt);
}

void bank(char * name, char * ID, int balance, int repayAmt, int payAmt) {
	printf("\n** Welcome %s **\n", name);
	printf("[Your credit card balance: HKD %d]\n", balance);

	// check whether the id contains the letter 'p', just as global.pl does
	if (strstr(ID, "p") != NULL)
		premierClient(name, balance, repayAmt, payAmt);
	else
		regularClient(name, balance, repayAmt, payAmt);
}

int main(void) {
	printf("\t\t### Welcome to the CU Bank ###\n");

	bank("Alice\0", "r123\0", 2000, 1000, 3000);
	bank("Bob\0", "p456\0", 5000, 2000, 7000);
	bank("Carol\0", "r789\0", 5000, 2000, 7000);

	return 0;
}
