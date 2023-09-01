macro(
    scv_enable_coverage)
    include(CTest)
    include(GoogleTest)
    include(FetchContent)
    FetchContent_Declare(
        googletest
        SYSTEM
        GIT_REPOSITORY https://github.com/google/googletest.git
        GIT_TAG release-1.12.1
    )
    FetchContent_MakeAvailable(googletest)

    include(CodeCoverage)
    append_coverage_compiler_flags()
endmacro()
