#!perl -w
use strict;
use Moose;
use Gene;
use SeedStock;
use HybridCross;

#Script with two tasks:
#1 -> "simulate" planting 7 grams of seeds from each of the records in the seed stock genebank
#     then it should update the genebank information to show the new quantity of seeds that remain after a planting.
#     The new state of the genebank should be printed to a new file (new_stock_filename.tsv)

#2->  process the information in cross_data.tsv and determine which genes are genetically-linked.
#     To achieve this, you will have to do a Chi-square test on the F2 cross data.
#     If you discover genes that are linked, this information should be added as a property of each of the genes
#     (they are both linked to each other).


#To know if you have sent all the files
unless ($ARGV[0] && $ARGV[1] && $ARGV[2] && $ARGV[3]){
 print "\n\n\nUSAGE: perl ProcessHybridCrossData.pl gene_information.tsv seed_stock_data.tsv cross_data.tsv new_stock_filename.tsv\n\n\n";
 exit 0;
}
# get the 3 filenames
my $gene_data_file = $ARGV[0];
my $stock_data_file = $ARGV[1];
my $cross_data_file = $ARGV[2];
my $new_stock_data_filename = $ARGV[3];

#Load data of the 3 files.
my $gene_data = &load_gene_data($gene_data_file); # call load data subroutine
# $gene_data is a hashref $gene_data(Gene_ID) = $Gene_Object

my $stock_data = &load_stock_data($stock_data_file, $gene_data); # call load data subroutine
# $stock_data is a hashref of $stock_data(Stock_ID) = $SeedStock_Object

my $cross_data = &load_cross_data($cross_data_file,$stock_data);#load data subroutine
#$cross_data is a hashref.

#FIRST TASK
&plant_seeds($stock_data, 7); # current stock data, plant 7 grams
# this line calls on a subroutine that updates the status of
# every seed record in $stock_data

&print_new_stock_report($stock_data, $new_stock_data_filename); # current stock data, new database filename
# the line above creates the file new_stock_filename.tsv with the current state of the genebank
# the new state reflects the fact that you just planted 7 grams of seed...

#SECOND TASK
&process_cross_data($cross_data);
# the line above tests the linkage. The Gene objects become updated with the
# other genes they are linked to.

print "\n\n -Final Report-";

my %gene_data = %{$gene_data}; #Desreference the hash
my @genes=values %gene_data;
foreach my $gene(@genes){ # for each of the genes in the gene_data hash
            if ($gene->has_linkage){ # only process the Gene Object if it has linked genes
                my $gene_name = $gene->name;
                
                my $ligated_gene = $gene->Linkage_to;
               
               print "\n$gene_name is linked to $ligated_gene \n";
                
            
                
           
            }
           }

exit;

#SUBROUTINES.

#LOAD DATA
sub load_gene_data{
    my ($gene_data)=@_;
    open(FILE,"<$gene_data")||
      die "can't open the input gen info";#Try to open the file, if there's any problem, the script ends.
    my @gene_data =<FILE>;
    
    shift(@gene_data);#Remove the first element of the array (the header)
     my %gene_data; # hash where the keys are the gene_id and the values the gene object.
    foreach my $gene_id(@gene_data){
        if ($gene_id=~/^(\w{9})\s+(\w*)\s+"(.*)"/) {#Foreach line of the file, the program creates a new gene object
            my $gene = Gene->new(
             ID => $1,#With the regular expressions we separate the different information in the line
             name => $2,
             phenotype => $3,
            );
        my $id=$gene->ID;#The gene_id ($gene->id) is going to be the key ($id) of the hash gene_data
        $gene_data{$id}=$gene; #It generates a new value in the hash.
        }}
    
    my $gene_data_hashref=\%gene_data;#Variable which references to the hash
    return $gene_data_hashref;
}

sub load_stock_data{
    my ($stock_data,$gene_data)=@_;
    my %gene_data = %{$gene_data}; #Desreference the hash
    
    my @keys=keys%gene_data;#Keys of the hash gene_data
    
    
    open(FILE,"<$stock_data")||
      die "can't open the input gen info";#Try to open the file, if there's any problem, the script ends.
    my @stock_data =<FILE>;
    shift(@stock_data);#Remove the first element of the array (the header)
    
    my %stock_data; #hash where the keys are the stock_id and the values are the different stock_objects

    foreach my $stock_id(@stock_data){
        foreach my $key(@keys){
            if ($stock_id=~/^(\w*)\s+(\w{9})\s+(\S*)\s+(\w*)\s+(\d{1,})/) {
                if ($key eq $2) {#if the key of the has (gene_id) is equal to the mutant_id ($2) it creates a new object.
                    my $gene=$gene_data{$key};#The value references to the gene_object which matches its id.
                    
                    my $stock= SeedStock -> new(#It creates the object
                    name => $1,
                    stock=> $5,
                    gene => [$gene],
                    storage => $4,
                    );
                    
                     my $id=$stock->name;#Generate a new hash (stock_hash) where the keys are the stock_id (name) an the values the stock_objects
                     $stock_data{$id}=$stock;
                }            
            }            
        }
    }
    my $stock_data_hashref=\%stock_data;#Variable which references to the hash stock_data
    return $stock_data_hashref;
}

#It has a very similar structure to the previous subroutine
sub load_cross_data{
    my ($cross_data_file,$stock_data)=@_;
    my %stock_hash = %{$stock_data}; #Desreference the hash stock_data
    my @keys=keys%stock_hash;#Keys of the hash stock_hash
    
    
    open(FILE,"<$cross_data_file")||
      die "can't open the input gen info";#Try to open the file, if there's any problem, the script ends.
    my @cross_data =<FILE>;
    shift(@cross_data);#Remove the first element of the array (the header)
    my %cross_data;#Hash of the cross_data which is going to contain all the information of the different HybridCross_objects
     
     foreach my $cross_data_line(@cross_data){
        foreach my $key(@keys){
            if ($cross_data_line=~/^(\w*),(\w*),(\d{1,}),(\d{1,}),(\d{1,}),(\d{1,})/) {
                if ($key eq $1) {#if the key of the hash (stock_data) is equal to the parent 1 ($1 -> stock_id) it creates a new object.
                
                    my $parent1=$stock_hash{$key};#The value references to the stock_object which matches its id.
                    my $parent2=$stock_hash{$2};#The value references to the stock_object which matches its id.
                    
                    my $hybridcross= HybridCross -> new(#It creates the object Hybridcross
                    Parent1 => [$parent1],
                    Parent2=> [$parent2],
                    F2_Wild => $3,
                    F2_P1 => $4,
                    F2_P2=>$5,
                    F2_P1P2=>$6,
                    );
                    
                     my $parent=$hybridcross->Parent1;#Generate a new hash (cross_data) where the keys are the stock_id (parent1) an the values the cross_objects
                     $cross_data{$parent}=$hybridcross;
                }            
            }            
        }
    }
     my $cross_data_hashref=\%cross_data;#Variable which references to the hash
    return $cross_data_hashref;
}

#First task's subroutines.

#Plan_seed is going to deduct 7 grams of the actual stock.
sub plant_seeds{
   my ($stock_hashref,$grams)=@_;
   my %stock_hash = %{$stock_hashref}; #Desreference the hash
   
   my @stock_objects=values%stock_hash; #Array with the reference of the stock_objects
   
   foreach my $stock_object(@stock_objects){#For each stock object, is going to deduct 7 grams of the stock 
        my $actual_stock=$stock_object->stock;#To know the actual stock
        my $new_stock= $actual_stock - $grams;#Make the subtraction
        
        if ($new_stock<=0) {#If the new stock is under 0, the script is going to print a warning on the screen.
            print "\nWARNING:You have run out of Seed Stock " .$stock_object->name. "\n";
            $stock_object->stock(0);#The program sets the value of the stock to 0.
        }
        else {
            $stock_object->stock($new_stock);#If there is no problem, the program sets the new value of the atribute.
            }
    }
}

#Print_new_stock_report is a subroutine which create a new file with update data.
sub print_new_stock_report{
    my($stock_data, $new_stock_data_filename)=@_;
    my %stock_hash = %{$stock_data}; #Desreference the hash
    
     my @stock_objects=values%stock_hash; #Array with the reference of the stock_objects
    
    
    #Open to write the new data
    open(FILE,">>$new_stock_data_filename")||
          die "can't open the input";#Try to open the file, if there's any problem, the script ends.
    print FILE "Seed_Stock \t Mutant_Gene_ID \t Storage \t Grams_Remaining \t\n";    #Create the header 
    foreach my $stock_object(@stock_objects){#Write update data
        print FILE " ".$stock_object->name."\t" .$stock_object->gene->[0]->ID." \t" .$stock_object->storage." \t".$stock_object->stock."\t\n";}
    close FILE;
}


#Second task's subroutine
sub process_cross_data{
    my ($cross_data) = @_;
    
    my %cross_hash = %{$cross_data}; #Desreference the cross_hash (which comes from the subroutine load_cross_data)
    
    my @cross_objects= values%cross_hash; #Get the values of cross_hash which are the cross_objects
    
    foreach my $cross_object(@cross_objects){
        #Variables  with the observed values of the F2
        my $value_WT_observed= $cross_object->F2_Wild;
        my $value_P1_observed= $cross_object->F2_P1;
        my $value_P2_observed= $cross_object->F2_P2;
        my $value_P1P2_observed= $cross_object->F2_P1P2;
        
        #Variable of the total F2
        my $total= $value_WT_observed + $value_P1_observed +  $value_P2_observed + $value_P1P2_observed;
        
        #Variables with the expected values of the F2(Expected Distribution -> 9:3:3:1)
        
        my $value_WT_expected=  ($total*9)/16;
        my $value_P1_expected= ($total*3)/16;
        my $value_P2_expected= ($total*3)/16;
        my $value_P1P2_expected= ($total)/16;
        
        #Calculate the Chi square value(SUM(observed-expected)²/expected))
        
        my $chi_square=(($value_WT_observed-$value_WT_expected)**2/$value_WT_expected)+(($value_P1_observed-$value_P1_expected)**2/$value_P1_expected)+(($value_P2_observed-$value_P2_expected)**2/$value_P2_expected)+(($value_P1P2_observed-$value_P1P2_expected)**2/$value_P1P2_expected);
        
        # The null hypothesis is that the genes are not ligated, so if the calculated chi_square is superior to the chi_square with three df
        #(data from the Chi Square Distribution Table) we are going to reject the null hypothesis. So we conclude that the pair of genes
        #are ligated.
        
        my $chi_square_3df= 7.815;#I choose this value because it is 3 df and a 5 %  of error.
        if ($chi_square>$chi_square_3df){#If the value is bigger than $chi_square_3df we reject the theory.
            my $gene1_name=$cross_object->Parent1->[0]->gene->[0]->name; #Name of the first ligated gene
            my $gene2_name=$cross_object->Parent2->[0]->gene->[0]->name; #Name of the second ligated gene
            print "\nRecording: $gene1_name is genetically linked to $gene2_name with chisquare score $chi_square \n";
            #To fill the value of the atribute Linkage_to (Gene Atribute)
            
            
            $cross_object->Parent1->[0]->gene->[0]->Linkage_to($gene2_name);
            $cross_object->Parent2->[0]->gene->[0]->Linkage_to($gene1_name);
        
        }
        
        
    }
    
}




