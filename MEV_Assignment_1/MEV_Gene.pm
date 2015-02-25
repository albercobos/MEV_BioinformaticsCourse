package Gene;use Moose;

#Gene.pm is an object with the following atributes:

has 'ID'=>(#Gene's id
    is=>'rw',
    isa=>'Str',
);

has 'name'=>(#Name of the gene
    is=>'rw',
    isa=>'Str',
);

has 'phenotype'=>(#Description of the mutated phenotype
     is=>'rw',
     isa=>'Str',    
);

has 'Linkage_to'=>(
    is=>'rw',
    isa=>'Str',
    predicate=>'has_linkage',
    
);

1;