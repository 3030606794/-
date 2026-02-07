using System;
using Avalonia.Controls;
using HLab.Mvvm.Annotations;

namespace LittleBigMouse.Ui.Avalonia.Plugins.Default;

public class DefaultMonitorViewModelDesign : DefaultMonitorViewModel, IDesignViewModel
{
    public DefaultMonitorViewModelDesign()
    {
        if(!Design.IsDesignMode) throw new InvalidOperationException("仅用于设计模式");

        //Monitor = new MonitorDesign();
    }
}