package Sqlite;

use strict;
use Exporter;
use DBI;
our @ISA = ('Exporter');

my $dbh;
my $sth;

##############################################################################

our @EXPORT = qw(&connectDB &executeSql);

##################################################################
# connectDB - open db-handle and connect to the desired database
##################################################################
sub connectDB {
    my $database = $_[0];
    
    # if (! -e $database) {
        # print "***ERROR: No ${database} found\n";
        # exit 1;
    # }
    
    # if ($database eq "" || ! defined $database) {
        # print "***ERROR: To less arguments\n";
        # print "usage: connectDB(databasefile)\n";
        # exit 1;
    # }
    
    my $driver   = "SQLite"; 
    my $dsn = "DBI:$driver:dbname=$database";
    my $userid = "";
    my $password = "";
    my $dbh = DBI->connect($dsn, $userid, $password, { RaiseError => 1 , AutoCommit => 1}) or die $DBI::errstr;
    
    return $dbh;
}


##################################################################
# executeSql - executes a sql-statement and returns the result 
##################################################################
sub executeSql  {
    my $db_handle = shift;
    my $sql = shift;
    my @parameters = @_;

    my $sth;
    my @row;
    
    if ((! defined $db_handle || $db_handle eq "") || (! defined $sql || $sql eq "")) {
        print "[usage]\n\texecuteSql(database-handle(DBI object),sql-script(string),[sql-parameters(array)])\n\n";
        exit 127;
    }
    
    $sth=$db_handle->prepare($sql) || die "Can't prepare statement: $DBI::errstr";
    # sql-parameters
    if (scalar(@parameters) > 0)  {
        my $paraNr=1;
        for (@parameters) {
            $sth->bind_param($paraNr,$_);
            $paraNr++;
        }
    }
    $sth->execute() or die "Can't prepare statement: $DBI::errstr";
    #$db_handle->commit();
    
    my @results;
    my $fields = $sth->{NAME};
    my @fields = @{$fields};

    while (@row = $sth->fetchrow_array) {
        my @array = @row;
        push (@results,\@array);
    }
    
    unshift (@results,\@fields);
    return @results;
}


1;
