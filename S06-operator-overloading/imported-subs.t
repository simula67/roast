use v6;
use Test;

plan 19;

BEGIN { @*INC.push: 't/spec/packages' };

{
    # defined in t/spec/packages/Exportops.pm
    use Exportops;

    # note that eval_dies_ok executes in the context of
    # Test.pm, and Test.pm doesn't import or lift the operators

    ok EVAL('5!'), 'postfix:<!> was exported...';
    ok EVAL('5! == 120 or die'), '... and it works';
    eval_dies_ok '5!', 'Test.pm does not import the operators';

    ok EVAL('"a" yadayada "b"'), 'infix:<yadayada> was exported';
    ok EVAL('"a" yadayada "b" eq "a..b" or die'), '... and it works';
    #?pugs todo
    ok EVAL('my $a = "a"; $a yadayada= "b"; $a eq "a..b" or die'), '... and yadayada= works too';

    ok EVAL('¢"foo"'), 'imported Unicode prefix operator';
    ok EVAL('¢4 eq "4 cent" or die '), '... and it works';

    ok EVAL('3 ± 4'), 'infix:<±> was exported';
    #?pugs todo
    ok EVAL('(3 ± 4).isa(Range) or die'), '... and it works';

    is EVAL("(NotANumber.new(:number(4)) NAN+ NotANumber.new(:number(-1))).number"), 3, "infix:<NAN+> was exported";
    is EVAL("(NotANumber.new(:number(4)) + NotANumber.new(:number(-1))).number"), 3, "multi infix:<+> was exported and is visible";
    
    #?pugs todo
    is EVAL('my $a = NotANumber.new(:number(4)); $a NAN+= NotANumber.new(:number(-1)); $a.number;'), 3, "NAN+= works too";
    is EVAL('my $a = NotANumber.new(:number(4)); $a += NotANumber.new(:number(-1)); $a.number;'), 3, "+= works too";
    
    is 4 + 2, 6, "Normal infix:<+> still works";

    #?pugs todo
    dies_ok { EVAL('3 notthere 4') }, 'not-exported operator was not imported';

    {
        #?pugs emit #
        my $fail = try EVAL q{3 notthere 4};
        #?pugs skip 'eek'
        ok $! ~~ X::Syntax::Confused, 'not imported operator fails with X::Syntax::Confused.';
        #?pugs skip 'eek'
        is $!.reason, "Two terms in a row", 'the reason is "Two terms in a row"';
    }
}

eval_dies_ok '5!', 'import of operators is lexical';

# vim: ft=perl6
