#include <any>
#include <cmath>
#include <functional>
#include <iostream>
#include <numeric>
#include <string>
#include <utility>

#include <TLexer.h>
#include <TParser.h>
#include <TParserBaseVisitor.h>
#include <antlr4-runtime.h>

#define EMIT_LOGS 0

#if EMIT_LOGS
#define LOG(FMT, ...) std::printf(FMT "\n", ##__VA_ARGS__)
#define LOG_VISIT(FMT, ...) std::printf("Visiting " FMT "\n", ##__VA_ARGS__)
#define LOG_RETURN(FMT, ...) std::printf("Returning " FMT "\n", ##__VA_ARGS__)
#else
#define LOG(...)
#define LOG_VISIT(...)
#define LOG_RETURN(...)
#endif

class TreeVisitor : public parser::TParserBaseVisitor
{
  public:
    std::any visitAtom(parser::TParser::AtomContext *ctx) override
    {
        LOG_VISIT("atom");
        if (ctx->expr()) {
            LOG_RETURN("expression");
            return visitExpr(ctx->expr());
        } else if (ctx->INT()) {
            LOG_RETURN("%s from INT atom", ctx->INT()->toString().c_str());
            return std::make_any<int>(std::stoi(ctx->INT()->toString()));
        } else {
            LOG_RETURN("default atom");
            return std::make_any<int>(97);
        }
    }

    std::any visitSignedAtom(parser::TParser::SignedAtomContext *ctx) override
    {
        LOG_VISIT("signed atom");
        if (ctx->atom()) {
            LOG_RETURN("atom");
            return visitAtom(ctx->atom());
        } else if (ctx->PLUS()) {
            LOG_RETURN("PLUS signedAtom");
            return visitSignedAtom(ctx->signedAtom());
        } else if (ctx->MINUS()) {
            int value = std::any_cast<int>(visitSignedAtom(ctx->signedAtom()));
            LOG_RETURN("from %d MINUS signedAtom", value);
            return std::make_any<int>(-1 * value);
        } else {
            LOG_RETURN("default");
            return defaultResult();
        }
    }

    std::any visitPowExpression(parser::TParser::PowExpressionContext *ctx) override
    {
        LOG_VISIT("pow expression");

        const auto atoms = ctx->signedAtom();
        std::vector<int> childResults;
        for (auto *expr : atoms) {
            int result = std::any_cast<int>(visitSignedAtom(expr));
            childResults.push_back(result);
        }

        int result =
            std::accumulate(childResults.begin() + 1, childResults.end(), childResults.front(), [](int a, int b) {
                return std::pow(a, b);
            });

        LOG_RETURN("%d from powExpression", result);
        return std::make_any<int>(result);
    }

    std::any visitMultiplyingExpression(parser::TParser::MultiplyingExpressionContext *ctx) override
    {
        LOG_VISIT("multiplying expression");

        const std::function<int(int, int)> op =
            (ctx->STAR().size() != 0) ? [](int a, int b) { return a * b; } : [](int a, int b) { return a / b; };

        const auto atoms = ctx->powExpression();
        std::vector<int> childResults;
        for (auto *expr : atoms) {
            int result = std::any_cast<int>(visitPowExpression(expr));
            childResults.push_back(result);
        }

        int result = std::accumulate(childResults.begin() + 1, childResults.end(), childResults.front(), op);

        LOG_RETURN("%d from multiplyingExpression", result);
        return std::make_any<int>(result);
    }

    std::any visitExpr(parser::TParser::ExprContext *ctx) override
    {
        LOG_VISIT("expression");

        const std::function<int(int, int)> op =
            (ctx->PLUS().size() != 0) ? [](int a, int b) { return a + b; } : [](int a, int b) { return a - b; };

        const auto atoms = ctx->multiplyingExpression();
        std::vector<int> childResults;
        for (auto *expr : atoms) {
            int result = std::any_cast<int>(visitMultiplyingExpression(expr));
            childResults.push_back(result);
        }

        int result = std::accumulate(childResults.begin() + 1, childResults.end(), childResults.front(), op);

        LOG_RETURN("%d from expression", result);
        return std::make_any<int>(result);
    }

    std::any visitStat(parser::TParser::StatContext *ctx) override
    {
        LOG_VISIT("statement");

        if (ctx->VAL()) {
            LOG_RETURN("default");
            return defaultResult();
        } else {
            LOG_RETURN("expression");
            return visitExpr(ctx->expr());
        }
    }

    std::any visitMain(parser::TParser::MainContext *ctx) override
    {
        LOG_VISIT("main");
        LOG_RETURN("children");
        return visitChildren(ctx);
    }

  private:
    virtual std::any defaultResult() override
    {
        LOG_VISIT("default");
        LOG_RETURN("1009 from default");
        return std::make_any<int>(1009);
    }
};

auto main() -> int
{
    std::vector<std::string> testInputs = {"2 * 10;", "8 - 10;", "24 / 3;", "2 ^ 3;"};

    for (const auto &str : testInputs) {
        std::cout << "Testing " << str << std::endl;

        antlr4::ANTLRInputStream input(str);

        parser::TLexer lexer(&input);
        antlr4::CommonTokenStream tokens(&lexer);

        tokens.fill();

        parser::TParser parser(&tokens);
        antlr4::tree::ParseTree *tree = parser.main();

        LOG("%s", tree->toStringTree(&parser).c_str());

        TreeVisitor visitor;
        const auto value = visitor.visit(tree);

        std::cout << "  Result: " << std::any_cast<int>(value) << std::endl;
    }

    return 0;
}
