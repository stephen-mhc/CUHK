# CSCI3180 Principles of Programming Languages
# ---Declaration---
# I declare that the assignment here submitted is original except for source material explicitly
# acknowledged. I also acknowledge that I am aware of University policy and regulations on honesty
# in academic work, and of the disciplinary guidelines and procedures applicable to breaches of
# such policy and regulations, as contained in the website
# http://www.cuhk.edu.hk/policy/academichonesty/
# Assignment 3
# Name: Stephen CHEONG Man Hoi
# Student ID: 1155043317
# Email Addr: stephencheong623@yahoo.com.hk

use feature ':5.10';
use warnings;

$creditLimit = 5000;

# name, ID, balance, repayAmt and payAmt can be lexical variables inside each subroutine since they don't need dynamic scoping
# they are only used inside their respective subroutine, or their values are passed to other subroutines
sub repayment {
    my ($name, $balance, $repayAmt) = @_;

    print "\n... Repaying debts ...\n";
    print "Thank you, $name! ";

    $balance -= $repayAmt;

    print "You have just repayed [HKD $repayAmt]!\n";

    my $currentLimit = $creditLimit - $balance ;
    print "Now your remaining credit limit is [HKD $currentLimit].\n";

    return $balance;
}

sub payment {
    my ($name, $balance, $payAmt) = @_;

    print "\n... Consumption payment (Luk Card) ...\n";

    my $currentLimit = $creditLimit - $balance;
    if ($currentLimit < $payAmt) {
        print "You have exceeded your credit limit!\n";
        return -1;
    }

    $currentLimit -= $payAmt;

    $balance += $payAmt;

    print "You have just payed a [HKD $payAmt] consumption!\n";

    print "Now your remaining credit limit is [HKD $currentLimit].\n";

    return $balance;
}

sub regularClient {
    my ($name, $balance, $repayAmt, $payAmt) = @_;

    # Repaying debts
    $balance = repayment($name, $balance, $repayAmt);

    if ($balance >= 0) {
        print "[Current card balance: HKD $balance]\n";
    }
    else {
        print "ERROR! You are trying to repay more than your debt amount!\n"
    }


    # Paying for consumption
    $balance = payment($name, $balance, $payAmt);

    if ($balance >= 0) {
        print "[Current card balance: HKD $balance]\n";
    }
    else {
        print "ERROR! You are trying to pay beyond your credit limit!\n"
    }
}

sub premierClient {
    my ($name, $balance, $repayAmt, $payAmt) = @_;

	# the only place where we need a local variable
	# here we want to carry the value of the premier creditLimit into all the subroutines called by the current subroutine premierClient, as well as into all further subroutines called
    local $creditLimit = 10000;

    print "Dear Premier client $name, you have a credit limit of [HKD $creditLimit]! Enjoy!\n";

    regularClient($name, $balance, $repayAmt, $payAmt);
}

sub bank {
    my ($name, $ID, $balance, $repayAmt, $payAmt) = @_;

    print "\n** Welcome $name **\n";
    print "[Your credit card balance: HKD $balance]\n";

    if ($ID =~ /p/) {
        premierClient($name, $balance, $repayAmt, $payAmt);
    }
    else {
        regularClient($name, $balance, $repayAmt, $payAmt);
    }
}


print "\t\t### Welcome to the CU Bank ###\n";

bank("Alice", "r123", 2000, 1000, 3000);
bank("Bob", "p456", 5000, 2000, 7000);
bank("Carol","r789", 5000, 2000, 7000);
