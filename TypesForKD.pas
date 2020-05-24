/// <summary>
///   Модуль обяаления типов для Keystroke Dynamics
/// </summary>
unit TypesForKD;

interface
type
      /// <summary>
      ///   Динамическая матрица вещественных чисел <br />
      /// </summary>
      TMatrixDouble = Array Of Array Of Double;
      /// <summary>
      ///   Динамический массив вещественых чисел
      /// </summary>
      TVector = Array Of Double;
      //TReal = Real;

type
  /// <summary>
  ///   Точка с веществеными координатами x и y
  /// </summary>
  TPoint = record
    x: Double;
    y: Double;
  end;

type
  /// <summary>
  ///   Массив вещественных точек
  /// </summary>
  TVectorPoints = Array Of TPoint;

implementation

end.
