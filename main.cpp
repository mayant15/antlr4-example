#include <iostream>

#include <antlr4-runtime.h>
#include <TLexer.h>
#include <TParser.h>

auto main() -> int {
    antlr4::ANTLRInputStream input(u8"🍴 = 🍐 + \"😎\";(((x * π))) * µ + ∰; a + (x * (y ? 0 : 1) + z);");

    parser::TLexer lexer(&input);
    antlr4::CommonTokenStream tokens(&lexer);

    tokens.fill();
    for (const auto& token : tokens.getTokens()) {
        std::cout << token->toString() << std::endl;
    }

    parser::TParser parser(&tokens);
    antlr4::tree::ParseTree *tree = parser.main();

    std::cout << tree->toStringTree(&parser) << std::endl;

    return 0;
}

