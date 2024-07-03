using CILHeader;
CILHeader cil @ 0x208;
struct CILHeader {
    u32 header_size;
    u16 major_runtime;
    u16 minor_runtime;
    u64 metadata;
    u32 flags;
    u32 entrypPointToken;
    u64 resources;
    u64 strongNameSig;
    u64 codeManagerTable;
    u64 vTableFixups;
    u64 ExportAddressTableJumps;
    u64 ManagedNativeHeader;
};
