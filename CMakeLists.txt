cmake_minimum_required(VERSION 3.20)
project(sample)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake)

set(ANTLR4_TAG 4.10.1)
add_definitions(-DANTLR4CPP_STATIC)

include(ExternalAntlr4Cpp)

set(ANTLR_EXECUTABLE ${PROJECT_SOURCE_DIR}/thirdparty/antlr4/antlr-4.10.1-complete.jar)
find_package(ANTLR REQUIRED)

antlr_target(SampleGrammarLexer TLexer.g4 LEXER PACKAGE parser)
antlr_target(SampleGrammarParser TParser.g4
    PARSER
    VISITOR
    PACKAGE parser
    DEPENDS_ANTLR SampleGrammarLexer
    COMPILE_FLAGS -lib ${ANTLR_SampleGrammarLexer_OUTPUT_DIR}
)

add_executable(sample
    main.cpp
    ${ANTLR_SampleGrammarLexer_CXX_OUTPUTS}
    ${ANTLR_SampleGrammarParser_CXX_OUTPUTS}
)
target_include_directories(sample PRIVATE
    ${ANTLR_SampleGrammarLexer_OUTPUT_DIR}
    ${ANTLR_SampleGrammarParser_OUTPUT_DIR}
)
target_link_libraries(sample PRIVATE antlr4_static)

