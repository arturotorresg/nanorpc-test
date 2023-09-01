#include <nanorpc/http/easy.h>
#include <iostream>

bool entrypoint([[maybe_unused]] const std::string & str)
{
    return true;
}

int main()
{
    try
    {
        auto server = nanorpc::http::easy::make_server(
            "0.0.0.0", "55555", 8, "/api/", std::pair{"setActiveDevice", entrypoint});

        std::cout << "Server started. Press Enter for quit." << std::endl;

        // This will effectively stop this thread from stopping, as we can not make any input
        std::cin.get();
    }
    catch (std::exception const &e)
    {
        std::cerr << "Error: " << nanorpc::core::exception::to_string(e) << std::endl;
        return false;
    }

    return 0;
}