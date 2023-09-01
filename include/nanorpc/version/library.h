//-------------------------------------------------------------------
//  Nano RPC
//  https://github.com/tdv/nanorpc
//  Created:     06.2018
//  Copyright (C) 2018 tdv
//-------------------------------------------------------------------

#ifndef __NANO_RPC_VERSION_LIBRARY_H__
#define __NANO_RPC_VERSION_LIBRARY_H__

namespace nanorpc::version::library
{

struct version final
{
    static constexpr int major() noexcept
    {
        return 1;
    }

    static constexpr int minor() noexcept
    {
        return 1;
    }

    static constexpr int patch() noexcept
    {
        return 1;
    }

    static constexpr char const* get_as_string() noexcept
    {
        return "1.1.1";
    }
};

}	// namespace nanorpc::version::library

#endif	// !__NANO_RPC_VERSION_LIBRARY_H__
