package App::lcpan::Cmd::backpan_author;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;
use Log::ger;

use Perinci::Object;

require App::lcpan;

our %SPEC;

$SPEC{handle_cmd} = {
    v => 1.1,
    summary => 'Open author page on BackPAN',
    description => <<'_',

Given author with CPAN ID `CPANID`, this will open
`http://BACKPAN_HOST/authors/id/C/CP/CPANID`. `CPANID` will first be checked for
existence in local index database.

_
    args => {
        %App::lcpan::common_args,
        %App::lcpan::authors_args,
    },
};
sub handle_cmd {
    my %args = @_;

    my $state = App::lcpan::_init(\%args, 'ro');
    my $dbh = $state->{dbh};

    my $envres = envresmulti();
    for my $author (@{ $args{authors} }) {
        my ($cpanid) = $dbh->selectrow_array(
            "SELECT cpanid FROM author WHERE cpanid=?", {}, uc $author);
        defined $cpanid or do {
            $envres->add_result(404, "No such author '$author'");
            next;
        };

        require Browser::Open;
        my $c = substr($cpanid, 0, 1);
        my $cp = substr($cpanid, 0, 2);
        my $url = "http://backpan.cpantesters.org/authors/id/$c/$cp/$cpanid";
        my $err = Browser::Open::open_browser($url);
        if ($err) {
            $envres->add_result(500, "Can't open browser for URL $url");
        } else {
            $envres->add_result(200, "OK");
        }
    }
    $envres->as_struct;
}

1;
# ABSTRACT:
