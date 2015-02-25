package HybridCross;
use Moose;
# HybridCroos is an object with the following atributes:

has 'Parent1'=>(#Parent 1
    is=>'rw',
    isa=>'ArrayRef[SeedStock]',
);

has 'Parent2'=>(#Parent 2
    is=>'rw',
    isa=>'ArrayRef[SeedStock]',
);

has 'F2_Wild'=>(#Number of plants with double dominance
    is=>'rw',
    isa=>'Int',
);

has 'F2_P1'=>(#Number of plants with dominance in Gene1
    is=>'rw',
    isa=>'Int',
);

has 'F2_P2'=>(#Number of plants with dominance in Gene2
    is=>'rw',
    isa=>'Int',
);

has 'F2_P1P2'=>(#Number of plants with recessive genes
    is=>'rw',
    isa=>'Int',
);
1;