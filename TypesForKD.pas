/// <summary>
///   ������ ��������� ����� ��� Keystroke Dynamics
/// </summary>
unit TypesForKD;

interface
type
      /// <summary>
      ///   ������������ ������� ������������ ����� <br />
      /// </summary>
      TMatrixDouble = Array Of Array Of Double;
      /// <summary>
      ///   ������������ ������ ����������� �����
      /// </summary>
      TVector = Array Of Double;
      //TReal = Real;

type
  /// <summary>
  ///   ����� � ������������ ������������ x � y
  /// </summary>
  TPoint = record
    x: Double;
    y: Double;
  end;

type
  /// <summary>
  ///   ������ ������������ �����
  /// </summary>
  TVectorPoints = Array Of TPoint;

implementation

end.
