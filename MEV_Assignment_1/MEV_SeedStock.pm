package SeedStock;
use Moose;

#SeedStock is an object with the following atributes:
has 'name'=>(#Name of the Seed Stock
    is=>'rw',
    isa=>'Str',
    
);

has 'stock'=>(#Grams remaining
    is=>'rw',
    isa=>'Int',
);

has 'date'=>(#Last date when they were planted
    is=>'rw',
    isa=>'Date',
);

has 'gene'=> (#Name of the gene, which references to the Gene_Object.
    is=>'rw',
    isa=>'ArrayRef[Gene]',
);

has 'storage'=>(#Storage where it is keeped
    is=>'rw',
    isa=>'Str',               
);
1;
