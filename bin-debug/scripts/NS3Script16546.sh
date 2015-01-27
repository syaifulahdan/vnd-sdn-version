//UNDER DEVELOPMENT
//##########################################
//Script created by VND - Visual Network Description (SDN version)
//##########################################
#include "ns3/core-module.h"
#include "ns3/network-module.h"
#include "ns3/mobility-module.h"
#include "ns3/config-store-module.h"
#include "ns3/wifi-module.h"
#include "ns3/internet-module.h"
#include "ns3/point-to-point-module.h"
#include "ns3/applications-module.h"
#include "ns3/csma-channel.h"
#include "ns3/csma-net-device.h"
#include "ns3/csma-module.h"
#include "ns3/csma-helper.h"
#include "ns3/internet-stack-helper.h"
#include "ns3/log.h"

#include <iostream>
#include <fstream>
#include <vector>
#include <string>

using namespace ns3;

NS_LOG_COMPONENT_DEFINE ("FirstScriptExample");

bool verbose = false;
bool use_drop = false;
ns3::Time timeout = ns3::Seconds (0);

bool SetVerbose (std::string value){
verbose = true;
return true;}

bool SetDrop (std::string value){
use_drop = true;
return true;}

bool SetTimeout (std::string value){
try {
timeout = ns3::Seconds (atof (value.c_str ()));
return true;}
catch (...) { return false; }
return false;}

int main (int argc, char *argv[]){
Time::SetResolution (Time::NS);
#ifdef NS3_OPENFLOW

  CommandLine cmd;
  cmd.AddValue ("v", "Verbose (turns on logging).", MakeCallback (&SetVerbose));
  cmd.AddValue ("verbose", "Verbose (turns on logging).", MakeCallback (&SetVerbose));
  cmd.AddValue ("d", "Use Drop Controller (Learning if not specified).", MakeCallback (&SetDrop));
  cmd.AddValue ("drop", "Use Drop Controller (Learning if not specified).", MakeCallback (&SetDrop));
  cmd.AddValue ("t", "Learning Controller Timeout (has no effect if drop controller is specified).", MakeCallback ( &SetTimeout));
  cmd.AddValue ("timeout", "Learning Controller Timeout (has no effect if drop controller is specified).", MakeCallback ( &SetTimeout));

  cmd.Parse (argc, argv);

  if (verbose){
  LogComponentEnable ("OpenFlowCsmaSwitchExample", LOG_LEVEL_INFO);
  LogComponentEnable ("OpenFlowInterface", LOG_LEVEL_INFO);
  LogComponentEnable ("OpenFlowSwitchNetDevice", LOG_LEVEL_INFO);
  LogComponentEnable ("UdpEchoClientApplication", LOG_LEVEL_INFO);
  LogComponentEnable ("UdpEchoServerApplication", LOG_LEVEL_INFO);}

  NodeContainer computer_1;
  computer_1.Create (1);
  NodeContainer computer_2;
  computer_2.Create (1);
  NodeContainer switchOpenflow_3;
  switchOpenflow_3.Create (1);


  NS_LOG_INFO ("Building links.");
  CsmaHelper csma_bridge_3_2;
  csma_bridge_3_2.SetChannelAttribute ("DataRate", StringValue ("1"));
  csma_bridge_3_2.SetChannelAttribute ("Delay", StringValue ("1"));
  CsmaHelper csma_bridge_3_1;
  csma_bridge_3_1.SetChannelAttribute ("DataRate", StringValue ("2"));
  csma_bridge_3_1.SetChannelAttribute ("Delay", StringValue ("2"));


  NS_LOG_INFO ("Building link net device container.");
  NodeContainer all_switchOpenflow_3_computer_2;
  all_switchOpenflow_3_computer_2.Add (switchOpenflow_3);
  all_switchOpenflow_3_computer_2.Add (computer_2);
  NetDeviceContainer ndc_p3p2 = csma_bridge_3_2.Install (all_switchOpenflow_3_computer_2);
  NodeContainer all_switchOpenflow_3_computer_1;
  all_switchOpenflow_3_computer_1.Add (switchOpenflow_3);
  all_switchOpenflow_3_computer_1.Add (computer_1);
  NetDeviceContainer ndc_p3p1 = csma_bridge_3_1.Install (all_switchOpenflow_3_computer_1);

  NS_LOG_INFO ("PCAP CONFIGURATION.");
  csma_bridge_3_2.EnablePcapAll(all_switchOpenflow_3_computer_2);
  csma_bridge_3_1.EnablePcapAll(all_switchOpenflow_3_computer_1);

  NS_LOG_INFO ("Install the IP stack.");
  InternetStackHelper internetStackH;
  internetStackH.Install (computer_1);
  internetStackH.Install (computer_2);
  internetStackH.Install (switchOpenflow_3);

  //Addressing...
  Ipv4AddressHelper address;
  address.SetBase ("10.0.0.1", "255.0.0.0");
  Ipv4InterfaceContainer iface_switchOpenflow_3_computer_2 = address.Assign (ndc_p3p2);
  address.SetBase ("10.0.0.1", "255.0.0.0");
  Ipv4InterfaceContainer iface_switchOpenflow_3_computer_1 = address.Assign (ndc_p3p1);

  UdpEchoServerHelper echoServer0 (9);

  ApplicationContainer serverApps2 = echoServer0.Install (computer_1.Get (0));
  ApplicationContainer serverApps3 = echoServer0.Install (computer_2.Get (0));
  ApplicationContainer serverApps4 = echoServer0.Install (switchOpenflow_3.Get (0));
  serverApps2.Start (Seconds (1.0));
  serverApps3.Start (Seconds (1.0));
  serverApps4.Start (Seconds (1.0));

  serverApps2.Stop (Seconds (10.0));
  serverApps3.Stop (Seconds (10.0));
  serverApps4.Stop (Seconds (10.0));

  UdpEchoClientHelper echoClient0 (iface_switchOpenflow_3_computer_2.GetAddress (1), 9);
  echoClient0.SetAttribute ("MaxPackets", UintegerValue (1));
  echoClient0.SetAttribute ("Interval", TimeValue (Seconds (1.0)));
  echoClient0.SetAttribute ("PacketSize", UintegerValue (1024));

  UdpEchoClientHelper echoClient1 (iface_switchOpenflow_3_computer_1.GetAddress (1), 9);
  echoClient1.SetAttribute ("MaxPackets", UintegerValue (1));
  echoClient1.SetAttribute ("Interval", TimeValue (Seconds (1.0)));
  echoClient1.SetAttribute ("PacketSize", UintegerValue (1024));


  ApplicationContainer clientApps2 = echoClient0.Install (computer_1.Get (0));
  ApplicationContainer clientApps3 = echoClient0.Install (computer_2.Get (0));
  ApplicationContainer clientApps4 = echoClient0.Install (switchOpenflow_3.Get (0));
  clientApps2.Start (Seconds (2.0));
  clientApps3.Start (Seconds (2.0));
  clientApps4.Start (Seconds (2.0));
  clientApps2.Stop (Seconds (10.0));
  clientApps3.Stop (Seconds (10.0));
  clientApps4.Stop (Seconds (10.0));

  NS_LOG_INFO ("Run Simulation.");
  Simulator::Run ();
  Simulator::Destroy ();
  NS_LOG_INFO ("Done.");
  #else
  NS_LOG_INFO ("NS-3 OpenFlow is not enabled. Cannot run simulation.");
  #endif
}

//###################################################################
//Do you want to contribute for development of automatic NS3 code? Please contact me via email: ramonreisfontes@gmail.com
//###################################################################
