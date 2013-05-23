#include "app/HelloWorld/HelloWorld.hpp"
#include "ebb/SharedRoot.hpp"
#include "ebb/EbbManager/PrimitiveEbbManager.hpp"
#include "ebb/MemoryAllocator/SimpleMemoryAllocator.hpp"
#include "lrt/console.hpp"

namespace {
  ebbrt::EbbRoot* construct_root()
  {
    return new ebbrt::SharedRoot<ebbrt::HelloWorldApp>;
  }
}

ebbrt::app::Config::InitEbb init_ebbs[] =
{
  {.id = ebbrt::memory_allocator,
   .create_root = ebbrt::SimpleMemoryAllocatorConstructRoot},
  {.id = ebbrt::ebb_manager,
   .create_root = ebbrt::PrimitiveEbbManagerConstructRoot},
  {.id = ebbrt::app_ebb,
   .create_root = construct_root}
};

const ebbrt::app::Config ebbrt::app::config = {
  .node_id = 0,
  .num_init = 3,
  .init_ebbs = init_ebbs
};

void
ebbrt::HelloWorldApp::Start()
{
  lock_.Lock();
  lrt::console::write("Hello World\n");
  lock_.Unlock();
  // if (get_location() == 0) {
  //   pci = Ebb<PCI>(ebb_manager->AllocateId());
  //   ebb_manager->Bind(PCI::ConstructRoot, pci);
  //   Ebb<Ethernet> ethernet{ebb_manager->AllocateId()};
  //   ebb_manager->Bind(VirtioNet::ConstructRoot, ethernet);
  //   char* buffer = static_cast<char*>(ethernet->Allocate(64));

  //   // destination mac address, broadcast
  //   buffer[0] = 0xff;
  //   buffer[1] = 0xff;
  //   buffer[2] = 0xff;
  //   buffer[3] = 0xff;
  //   buffer[4] = 0xff;
  //   buffer[5] = 0xff;

  //   // ethertype (protocol number) that is free
  //   buffer[12] = 0x88;
  //   buffer[13] = 0x12;
  //   std::strcpy(&buffer[14], "Hello World!\n");
  //   ethernet->Send(buffer, 64);
  // }
}
