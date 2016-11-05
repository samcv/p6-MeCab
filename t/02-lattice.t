use Test;
use MeCab;
use MeCab::Lattice;
use MeCab::Tagger;
use MeCab::Model;

subtest {
    my MeCab::Model $model .= new;

    my MeCab::Tagger $tagger = $model.create-tagger;
    my MeCab::Lattice $lattice = $model.create-lattice;
    if $tagger.parse($lattice) {
        is $lattice.size, 0;
    }
}, "Given an empty sentence, then MeCab::Lattice.size should return 0";

subtest {
    my MeCab::Model $model .= new;
    my MeCab::Tagger $tagger = $model.create-tagger;
    my MeCab::Lattice $lattice = $model.create-lattice;
    $lattice.sentence("シジル");
    is $lattice.sentence, "シジル";
}, "Given a text with the setter method, then MeCab::Lattice.sentence should return the same text";

subtest {
    my MeCab::Model $model .= new;
    my MeCab::Tagger $tagger = $model.create-tagger;
    my MeCab::Lattice $lattice .= new;
    $lattice.sentence("シジル");
    $lattice.clear;
    nok $lattice.sentence.defined;
}, "MeCab::Lattice.clear should clear the contents";

subtest {
    my MeCab::Model $model .= new;
    my MeCab::Tagger $tagger = $model.create-tagger;
    my MeCab::Lattice $lattice = $model.create-lattice;
    $lattice.sentence("見ざる、聞かざる、言わざる");
    if $tagger.parse($lattice) {
        is $lattice.is-available, True;
    }
}, "Given a fulfilled MeCab::Lattice instance, then MeCab::Lattice.is-available should return True";

subtest {
    my MeCab::Model $model .= new;
    my MeCab::Tagger $tagger = $model.create-tagger;
    my MeCab::Lattice $lattice = $model.create-lattice;
    $lattice.sentence("見ざる、聞かざる、言わざる");
    if $tagger.parse($lattice) {
        is $lattice.bos-node.surface, '';
        is $lattice.bos-node.feature, "BOS/EOS,*,*,*,*,*,*,*,*";
        is $lattice.bos-node.isbest, True;
        is $lattice.bos-node.stat, MECAB_BOS_NODE;
    }
}, "Given a fulfilled MeCab::Lattice instance, then MeCab::Lattice.bos-node should return a defined MeCab::Node";

subtest {
    my MeCab::Model $model .= new;
    my MeCab::Tagger $tagger = $model.create-tagger;
    my MeCab::Lattice $lattice = $model.create-lattice;
    $lattice.sentence("見ざる、聞かざる、言わざる");
    if $tagger.parse($lattice) {
        is $lattice.eos-node.surface, '';
        is $lattice.eos-node.feature, "BOS/EOS,*,*,*,*,*,*,*,*";
        is $lattice.eos-node.isbest, True;
        is $lattice.eos-node.stat, MECAB_EOS_NODE;
    }
}, "Given a fulfilled MeCab::Lattice instance, then MeCab::Lattice.eos-node should return a defined MeCab::Node";

todo 'RT #127452', 1;
subtest {
    my MeCab::Model $model .= new;
    my @texts = (("私","僕") xx 3).flat;

    my @actual = (@texts.hyper(:batch(1))\
                  .map(
                         {
                             my MeCab::Tagger $tagger = $model.create-tagger;
                             my MeCab::Lattice $lattice = $model.create-lattice;
                             $lattice.sentence($_);
                             $lattice.tostr if $tagger.parse($lattice);
                         }
                     ).list);
    
    my Str $r1 = ("私\t名詞,代名詞,一般,*,*,*,私,ワタシ,ワタシ\nEOS\n");
    my Str $r2 = ("僕\t名詞,代名詞,一般,*,*,*,僕,ボク,ボク\nEOS\n");
    my @expected = (($r1, $r2) xx 3).flat;
    is @actual, @expected;
}, "MeCab::Tagger should work in the multithread environment";

subtest {
    my MeCab::Model $model .= new;
    my MeCab::Tagger $tagger = $model.create-tagger;
    my MeCab::Lattice $lattice = $model.create-lattice;
    $lattice.request-type(MECAB_ONE_BEST);
    is $lattice.request-type, MECAB_ONE_BEST;
}, "Given a RequestType with the setter method, then MeCab::Lattice.request-type should return the same type";

subtest {
    my MeCab::Model $model .= new;
    my MeCab::Tagger $tagger = $model.create-tagger;
    my MeCab::Lattice $lattice = $model.create-lattice;
    is $lattice.has-constraint, False;
}, "When none constraints are set, then MeCab::Lattice.has-constraint should return False";

subtest {
    my MeCab::Model $model .= new;
    my MeCab::Tagger $tagger = $model.create-tagger;
    my MeCab::Lattice $lattice = $model.create-lattice;
    $lattice.boundary-constraint(0, MECAB_ANY_BOUNDARY);
    is $lattice.has-constraint, True;
}, "When constraints are set, then MeCab::Lattice.has-constraint should return True";

subtest {
    my MeCab::Model $model .= new;
    my MeCab::Tagger $tagger = $model.create-tagger;
    my MeCab::Lattice $lattice = $model.create-lattice;
    $lattice.sentence("thisis");
    $lattice.boundary-constraint(0, MECAB_TOKEN_BOUNDARY);
    $lattice.boundary-constraint(1, MECAB_INSIDE_TOKEN);
    $lattice.boundary-constraint(2, MECAB_INSIDE_TOKEN);
    $lattice.boundary-constraint(3, MECAB_INSIDE_TOKEN);
    $lattice.boundary-constraint(4, MECAB_TOKEN_BOUNDARY);
    $lattice.boundary-constraint(5, MECAB_INSIDE_TOKEN);
    $lattice.boundary-constraint(6, MECAB_TOKEN_BOUNDARY);
    is $lattice.boundary-constraint(0), MECAB_TOKEN_BOUNDARY;
    is $lattice.boundary-constraint(1), MECAB_INSIDE_TOKEN;
    is $lattice.boundary-constraint(2), MECAB_INSIDE_TOKEN;
    is $lattice.boundary-constraint(3), MECAB_INSIDE_TOKEN;
    is $lattice.boundary-constraint(4), MECAB_TOKEN_BOUNDARY;
    is $lattice.boundary-constraint(5), MECAB_INSIDE_TOKEN;
    is $lattice.boundary-constraint(6), MECAB_TOKEN_BOUNDARY;

    my @actual;
    if $tagger.parse($lattice) {
        @actual = $lattice.tostr.split("\n");
    }
    is @actual[0], "this\t名詞,固有名詞,組織,*,*,*,*";
    is @actual[1], "is\t名詞,一般,*,*,*,*,*";
    is @actual[2], "EOS";
},"Given the text \"thisis\" and the boundary constraints, then MeCab::Tagger.parse(MeCab::Lattice) method should divide the given text so that the resulting text is \"this is\"";

subtest {
    my MeCab::Model $model .= new;
    my MeCab::Tagger $tagger = $model.create-tagger;
    my MeCab::Lattice $lattice = $model.create-lattice;
    $lattice.sentence("thisisatest");

    $lattice.feature-constraint(0, 4, "名詞");
    $lattice.feature-constraint(4, 6, "名詞");
    $lattice.feature-constraint(6, 7, "名詞");
    $lattice.feature-constraint(7, 11, "名詞");

    my @actual;
    if $tagger.parse($lattice) {
        @actual = $lattice.tostr.split("\n");
    }
    is @actual[0], "this\t名詞,固有名詞,組織,*,*,*,*";
    is @actual[1], "is\t名詞,一般,*,*,*,*,*";
    is @actual[2], "a\t名詞,一般,*,*,*,*,*";
    is @actual[3], "test\t名詞,固有名詞,組織,*,*,*,*";
    is @actual[4], "EOS";
}, "Given the text \"thisisatest\" and the feature constraints, then MeCab::Tagger.parse(MeCab::Lattice) method should divide the given text so that the resulting text is \"this is a test\" and the all of the words are tagged as noun";

subtest {
    my MeCab::Model $model .= new;
    my MeCab::Tagger $tagger = $model.create-tagger;
    my MeCab::Lattice $lattice = $model.create-lattice;
    $lattice.add-request-type(MECAB_NBEST);
    $lattice.sentence("今日も");

    my $actual;
    if $tagger.parse($lattice) {
        $actual = $lattice.nbest-tostr(2);
    }
    my $expected = ("今日\t名詞,副詞可能,*,*,*,*,今日,キョウ,キョー",
                    "も\t助詞,係助詞,*,*,*,*,も,モ,モ",
                    "EOS",
                    "今日\t名詞,副詞可能,*,*,*,*,今日,コンニチ,コンニチ",
                    "も\t助詞,係助詞,*,*,*,*,も,モ,モ",
                    "EOS\n").join("\n");
    is $actual, $expected;
    
}, "MeCab::Lattice.nbest-tostr(2) should return the two results";

done-testing;
