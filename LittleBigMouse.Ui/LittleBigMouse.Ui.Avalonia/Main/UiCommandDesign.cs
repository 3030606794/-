using System;
using Avalonia.Controls;
using LittleBigMouse.Plugins.Avalonia;

namespace LittleBigMouse.Ui.Avalonia.Main;

public class UiCommandDesign : UiCommand
{
    public UiCommandDesign():base("Design")
    {
        if(!Design.IsDesignMode) throw new NotSupportedException("仅用于设计模式");

        IconPath = "Icon/Parts/Power";
        ToolTipText = "设置";
    }
}