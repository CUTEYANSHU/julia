nested_error_expr = quote
    try
        __not_a_binding__
    catch
        1 ÷ 0  # Generate error while handling error
    end
end

nested_error_pattern = r"""
    ERROR: DivideError: integer division error
    Stacktrace:.*
    caused by \[exception 1\]
    UndefVarError: __not_a_binding__ not defined
    Stacktrace:.*
    """s

@testset "display_error" begin
    # Display of errors which cause more than one entry on the exception stack
    err_str = try
        eval(nested_error_expr)
    catch
        excs = current_exceptions()
        @test typeof.(first.(excs)) == [UndefVarError, DivideError]
        sprint(Base.display_error, excs)
    end
    @test occursin(nested_error_pattern, err_str)
end