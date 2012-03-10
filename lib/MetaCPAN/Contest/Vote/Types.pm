package MetaCPAN::Contest::Vote::Types;

use MooseX::Types -declare => ['Ballot', 'EmptyString'];
use MooseX::Types::Moose 'Str', 'ArrayRef';
use MooseX::Types::URI 'Uri';
use MooseX::Types::Structured 'Dict';
use MooseX::Types::Common::Numeric 'PositiveInt', 'PositiveOrZeroInt';

subtype EmptyString, as Str, where { length $_ == 0 };

subtype Ballot, as ArrayRef[
    Dict[
        name  => Str,  # I'd like to use Uri here, but I can't be arsed to
                       # coerce first
        score => PositiveInt|EmptyString,
        title => Str,
        id    => PositiveOrZeroInt,
    ],
];

1;
