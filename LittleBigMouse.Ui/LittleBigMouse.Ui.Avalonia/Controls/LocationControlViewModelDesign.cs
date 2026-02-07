using System.Collections.Generic;
using HLab.Mvvm.Annotations;
using LittleBigMouse.Ui.Avalonia.Options;

namespace LittleBigMouse.Ui.Avalonia.Controls;

public class LocationControlViewModelDesign : IDesignViewModel
{
    public List<ListItem> AlgorithmList { get; } = new()
    {
        new ("strait","直线","简单且 CPU 占用低的切换方式。"),
        new ("cross","拐角穿越","更符合方向直觉，允许从拐角处穿越。"),

    };

    public object SelectedAlgorithm { get; set; } = "Strait";
}