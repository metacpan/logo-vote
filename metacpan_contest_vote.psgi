use strict;
use warnings;

use MetaCPAN::Contest::Vote;

my $app = MetaCPAN::Contest::Vote->apply_default_middlewares(MetaCPAN::Contest::Vote->psgi_app);
$app;

