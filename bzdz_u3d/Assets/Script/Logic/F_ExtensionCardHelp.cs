using FairyGUI;

public class F_ExtensionCardHelp
{
    public static void Extension(string strUrl)
    {
        UIObjectFactory.SetPackageItemExtension(strUrl, typeof(F_ExtensionCard));
    }
    public static F_ExtensionCard ConversionCard(object obj)
    {
        return (F_ExtensionCard)obj;
    }
}
