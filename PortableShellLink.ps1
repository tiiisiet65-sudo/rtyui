# Create portable .lnk: shortcut will find Download.macOSx.vbs next to .lnk file after copying.
# Co che: IShellLink + IShellLinkDataList.SetFlags(SLDF_FORCE_NO_LINKINFO | SLDF_FORCE_NO_LINKTRACK).

Add-Type -Language CSharp -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
using System.Text;

namespace LnkPortable
{
    [Flags]
    public enum SHELL_LINK_DATA_FLAGS : uint
    {
        SLDF_FORCE_NO_LINKINFO = 0x00000100,
        SLDF_FORCE_NO_LINKTRACK = 0x00040000
    }

    [ComImport, Guid("45e2b4ae-b1c3-11d0-b92f-00a0c90312e1"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IShellLinkDataList
    {
        [PreserveSig] int AddDataBlock(IntPtr pDataBlock);
        [PreserveSig] int CopyDataBlock(uint dwSig, out IntPtr ppDataBlock);
        [PreserveSig] int RemoveDataBlock(uint dwSig);
        [PreserveSig] int GetFlags(out uint pdwFlags);
        [PreserveSig] int SetFlags(uint dwFlags);
    }

    [ComImport, Guid("0000010b-0000-0000-C000-000000000046"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IPersistFile
    {
        [PreserveSig]
        int GetClassID(out Guid pClassID);
        [PreserveSig]
        int IsDirty();
        [PreserveSig]
        int Load([MarshalAs(UnmanagedType.LPWStr)] string pszFileName, uint dwMode);
        [PreserveSig]
        int Save([MarshalAs(UnmanagedType.LPWStr)] string pszFileName, [MarshalAs(UnmanagedType.Bool)] bool fRemember);
        [PreserveSig]
        int SaveCompleted([MarshalAs(UnmanagedType.LPWStr)] string pszFileName);
        [PreserveSig]
        int GetCurFile([MarshalAs(UnmanagedType.LPWStr)] out string ppszFileName);
    }

    [ComImport, Guid("000214F9-0000-0000-C000-000000000046"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IShellLinkW
    {
        void GetPath([Out, MarshalAs(UnmanagedType.LPWStr)] StringBuilder pszFile, int cchMaxPath, IntPtr pfd, uint fFlags);
        void GetIDList(out IntPtr ppidl);
        void SetIDList(IntPtr pidl);
        void GetDescription([Out, MarshalAs(UnmanagedType.LPWStr)] StringBuilder pszName, int cchMaxName);
        void SetDescription([MarshalAs(UnmanagedType.LPWStr)] string pszName);
        void GetWorkingDirectory([Out, MarshalAs(UnmanagedType.LPWStr)] StringBuilder pszDir, int cchMaxPath);
        void SetWorkingDirectory([MarshalAs(UnmanagedType.LPWStr)] string pszDir);
        void GetArguments([Out, MarshalAs(UnmanagedType.LPWStr)] StringBuilder pszArgs, int cchMaxPath);
        void SetArguments([MarshalAs(UnmanagedType.LPWStr)] string pszArgs);
        void GetHotkey(out short pwHotkey);
        void SetHotkey(short wHotkey);
        void GetShowCmd(out int piShowCmd);
        void SetShowCmd(int iShowCmd);
        void GetIconLocation([Out, MarshalAs(UnmanagedType.LPWStr)] StringBuilder pszIconPath, int cchIconPath, out int piIcon);
        void SetIconLocation([MarshalAs(UnmanagedType.LPWStr)] string pszIconPath, int iIcon);
        void SetRelativePath([MarshalAs(UnmanagedType.LPWStr)] string pszPathRel, uint dwReserved);
        void Resolve(IntPtr hwnd, uint fFlags);
        void SetPath([MarshalAs(UnmanagedType.LPWStr)] string pszFile);
    }

    public static class PortableShortcut
    {
        public static void Create(string linkPath, string targetPathFull, string iconPath, string description)
        {
            var clsid = new Guid("00021401-0000-0000-C000-000000000046");
            var t = Type.GetTypeFromCLSID(clsid, true);
            object unk = Activator.CreateInstance(t);
            var link = (IShellLinkW)unk;
            var dataList = (IShellLinkDataList)unk;
            uint f;
            int hr = dataList.GetFlags(out f);
            if (hr != 0) Marshal.ThrowExceptionForHR(hr);
            f |= (uint)(SHELL_LINK_DATA_FLAGS.SLDF_FORCE_NO_LINKINFO | SHELL_LINK_DATA_FLAGS.SLDF_FORCE_NO_LINKTRACK);
            hr = dataList.SetFlags(f);
            if (hr != 0) Marshal.ThrowExceptionForHR(hr);

            link.SetPath(targetPathFull);
            link.SetDescription(description);
            if (!string.IsNullOrEmpty(iconPath))
                link.SetIconLocation(iconPath, 0);

            var pf = (IPersistFile)unk;
            int hrSave = pf.Save(linkPath, true);
            if (hrSave != 0)
                Marshal.ThrowExceptionForHR(hrSave);
            Marshal.ReleaseComObject(unk);
        }
    }
}
'@ -ErrorAction Stop

function New-PortableShellLink {
    param(
        [Parameter(Mandatory)][string] $LinkPath,
        [Parameter(Mandatory)][string] $TargetPath,
        [string] $IconPath = '',
        [string] $Description = ''
    )
    [LnkPortable.PortableShortcut]::Create($LinkPath, $TargetPath, $IconPath, $Description)
}
