$minutes = 2

# --------------------Do not edit below this line----------------------------------------

# Get the ID and security principal of the current user account

$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()

$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)

 

# Get the security principal for the Administrator role

$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator

 

# Check to see if we are currently running "as Administrator"

if ($myWindowsPrincipal.IsInRole($adminRole))

   {

   # We are running "as Administrator" - so change the title and background color to indicate this

   $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + " (Elevated)"

   $Host.UI.RawUI.BackgroundColor = "DarkBlue"

   clear-host

   }

else

   {

   # We are not running "as Administrator" - so relaunch as administrator

   

   # Create a new process object that starts PowerShell

   $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";

   

   # Specify the current script path and name as a parameter

   $newProcess.Arguments = "-WindowStyle Hidden ", "-ExecutionPolicy ByPass", $myInvocation.MyCommand.Definition;

 

   # Indicate that the process should be elevated

   $newProcess.Verb = "runas";

   

   # Start the new process

   [System.Diagnostics.Process]::Start($newProcess)

   

   # Exit from the current, unelevated, process

   exit

   }


$blockCode = @"
    [DllImport("user32.dll")]
    public static extern bool BlockInput(bool fBlockIt);
"@


$userInput = Add-Type -MemberDefinition $blockCode -Name UserInput -Namespace UserInput -PassThru

Add-Type -TypeDefinition @'
using System.Runtime.InteropServices;

[Guid("5CDF2C82-841E-4546-9722-0CF74078229A"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IAudioEndpointVolume {
  // f(), g(), ... are unused COM method slots. Define these if you care
  int f(); int g(); int h(); int i();
  int SetMasterVolumeLevelScalar(float fLevel, System.Guid pguidEventContext);
  int j();
  int GetMasterVolumeLevelScalar(out float pfLevel);
  int k(); int l(); int m(); int n();
  int SetMute([MarshalAs(UnmanagedType.Bool)] bool bMute, System.Guid pguidEventContext);
  int GetMute(out bool pbMute);
}
[Guid("D666063F-1587-4E43-81F1-B948E807363F"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IMMDevice {
  int Activate(ref System.Guid id, int clsCtx, int activationParams, out IAudioEndpointVolume aev);
}
[Guid("A95664D2-9614-4F35-A746-DE8DB63617E6"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IMMDeviceEnumerator {
  int f(); // Unused
  int GetDefaultAudioEndpoint(int dataFlow, int role, out IMMDevice endpoint);
}
[ComImport, Guid("BCDE0395-E52F-467C-8E3D-C4579291692E")] class MMDeviceEnumeratorComObject { }

public class Audio {
  static IAudioEndpointVolume Vol() {
    var enumerator = new MMDeviceEnumeratorComObject() as IMMDeviceEnumerator;
    IMMDevice dev = null;
    Marshal.ThrowExceptionForHR(enumerator.GetDefaultAudioEndpoint(/*eRender*/ 0, /*eMultimedia*/ 1, out dev));
    IAudioEndpointVolume epv = null;
    var epvid = typeof(IAudioEndpointVolume).GUID;
    Marshal.ThrowExceptionForHR(dev.Activate(ref epvid, /*CLSCTX_ALL*/ 23, 0, out epv));
    return epv;
  }
  public static float Volume {
    get {float v = -1; Marshal.ThrowExceptionForHR(Vol().GetMasterVolumeLevelScalar(out v)); return v;}
    set {Marshal.ThrowExceptionForHR(Vol().SetMasterVolumeLevelScalar(value, System.Guid.Empty));}
  }
  public static bool Mute {
    get { bool mute; Marshal.ThrowExceptionForHR(Vol().GetMute(out mute)); return mute; }
    set { Marshal.ThrowExceptionForHR(Vol().SetMute(value, System.Guid.Empty)); }
  }
}
'@


function Disable-UserInput($seconds) {
    $userInput::BlockInput($true)
    Start-Sleep $seconds
    $userInput::BlockInput($false)
}

[Audio]::Volume = 1
[Audio]::Mute = $false

Set-Location $PSScriptRoot
.\lock.ppsx
Disable-UserInput -seconds $($minutes * 60) | Out-Null
