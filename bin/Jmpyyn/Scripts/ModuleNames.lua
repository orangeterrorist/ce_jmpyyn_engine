symbols = createSymbolList();
symbols.register();
 
function onOpenProcess(pid)
    symbols.unregister();
    symbols = createSymbolList();
    symbols.register();
 
    reinitializeSymbolhandler();
 
    if (pid == 4) then
        return;
    end
 
    local proc = dbk_getPEProcess(pid);
    --printf("proc: %08X", proc);
 
    local peb = readQword(proc + 0x550);
    --printf("peb: %08X", peb);
 
    local ldr = readQword(peb + 0x18);
    --printf("ldr: %08X", ldr);
 
    local index = readQword(ldr + 0x10);
    --printf("index: %08X\n", index);
 
    while (index ~= ldr + 0x10) do
          local mod = readQword(index);
          --printf("mod: %08X", mod);
 
          local name = readString(readQword(mod + 0x58 + 0x8), readSmallInteger(mod + 0x58), true);
          --printf("name: %s", name);
 
          local base = readQword(mod + 0x30);
          --printf("base: %08X", base);
 
          local size = readInteger(mod + 0x40);
          --printf("size: %04X\n", size);
 
          symbols.addModule(name, "", base, size, true);
 
          index = readQword(mod);
    end
 
    local name = readString(proc + 0x5A8, 15);
    --print("name:", name);
 
    local base = readQword(proc + 0x520);
    --printf("base: %08X", base);
 
    local size = readQword(proc + 0x498);
    --printf("size: %04X", size);
 
    symbols.addModule(name, "", base, size);
 
    reinitializeSymbolhandler();
 
    --print("finished!");
end