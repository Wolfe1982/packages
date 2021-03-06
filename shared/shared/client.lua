local ffi = require('ffi');
local shared = require('shared')
local structs = require('structs')

local ffi_cast = ffi.cast
local ffi_cdef = ffi.cdef

local prepared = {}

local prepare_struct
local prepare_array

local setup_ftype = function(ftype)
    if ftype.count then
        prepare_array(ftype)
    elseif ftype.fields then
        prepare_struct(ftype)
    end

    local name = ftype.name
    if not name or prepared[name] then
        return
    end

    if ftype.fields then
        structs.name(ftype)
        structs.metatype(ftype)
    end

    prepared[name] = true
end

prepare_struct = function(struct)
    for label, field in pairs(struct.fields) do
        local ftype = field.type
        if ftype then
            setup_ftype(ftype)
        end

        local lookup = field.lookup
        if type(lookup) == 'function' then
            setfenv(lookup, _G)
        end
    end
end

prepare_array = function(array)
    local ftype = array.base
    if ftype then
        setup_ftype(ftype)
    end
end

return {
    new = function(service_name, name)
        name = name or 'data'

        local data_client = shared.get(service_name, service_name .. '_' .. name)
        local data = data_client:read()

        local ftype = data.ftype
        setup_ftype(ftype)

        return structs.from_ptr(ftype, data.ptr), ftype
    end,
}

--[[
Copyright © 2018, Windower Dev Team
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Windower Dev Team nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE WINDOWER DEV TEAM BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
