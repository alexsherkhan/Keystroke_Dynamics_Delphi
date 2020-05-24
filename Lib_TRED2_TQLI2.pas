/// <summary>
///   Модуль для нахождения собственных значений и собственных векторов
/// </summary>
unit Lib_TRED2_TQLI2;

interface
uses TypesForKD;

/// <summary>
///   Редукция Хаусхолдера <br />Приведение симметрической матрицы А к
///   трехдиагональной форме с помощью <br />преобразования Хаусхолдера с
///   использованием элементов нижнего треугольника <br />симметрической
///   матрицы. Исходная матрица А записана в массиве a[0..n-1,0..n-1]. <br />
///   Диагональные элементы результирующей матрицы накапливаются в массиве
///   d[0..n-1], <br />а поддиагональные в последних (n-1) ячейках массива
///   e[0..n-1]. <br />Матрица преобразования формируется в массиве
///   a[0..n-1,0..n-1].
/// </summary>
/// <param name="n">
///   Размерность матрицы
/// </param>
/// <param name="a">
///   Симметричная матрица
/// </param>
/// <param name="d">
///   Диагональные элементы матрицы
/// </param>
/// <param name="e">
///   Поддиагональные элементы матрицы <br />
/// </param>
procedure tred2(n : integer; tol : real; var a : tmatrixDouble; var d,e : tvector);

/// <summary>
///   Нахождение собственных значений и собственных векторов <br />симметричной
///   трехдиагональной матрицы. Исходная матрица задается <br />заданной двумя
///   векторам: d[i] - диагональные элементы матрицы, <br />а внедиагональные
///   элементы в последних (n-1) ячейках массива e[0..n-1]. <br />Если находим
///   собственные векторы матрицы приведенной к трехдиагональному <br />виду с
///   помощью процедуры tred2, то A содержит соответсвующую матрицу <br />
///   преобразования, в противном случае должна быть задана как единичная
///   матрица. <br />На выходе z-матрица собственных векторов, d - собственные
///   значения
/// </summary>
/// <param name="n">
///   Размерность матрицы
/// </param>
/// <param name="maxiter">
///   Максимальное количество итераций
/// </param>
/// <param name="z">
///   Матрица в трехдиагональной форме
/// </param>
/// <param name="d">
///   Диагональные элементы матрицы <br />
/// </param>
/// <param name="e">
///   Внедиагональные элементы матрицы
/// </param>
procedure tqli2(n,maxiter : integer; var z : tmatrixDouble; var d,e : tvector; var err : integer);

implementation

procedure tred2(n : integer; tol : real; var a : tmatrixDouble; var d,e : tvector);
var i,j,k,l : integer; f,g,h,hh : real;
begin
  SetLength(e,Length(a));
  SetLength(d,Length(a));
 dec(n);
 for i:=n downto 1 do
  begin
   l:=i-1;
   f:=a[i,l];
   g:=0.0;
   if l>=0 then for k:=0 to l-1 do g:=g+sqr(a[i,k]);
   h:=g+sqr(f);
     {преобразование Хаусхолдера не выполняется,если параметр g слишком мал,
      чтобы гарантировать ортогональность}
     if g>tol then
      begin
       if f>=0.0 then g:=-sqrt(h) else g:=sqrt(h);
       e[i]:=g;
       h:=h-f*g; a[i,l]:=f-g; f:=0.0;
       for j:=0 to l do
        begin
         a[j,i]:=a[i,j]/h; g:=0.0;
         {формирование вектора A*u}
         for k:=0 to j do g:=g+a[j,k]*a[i,k];
         for k:=j+1 to l do g:=g+a[k,j]*a[i,k];
         {формирование вектора p}
         e[j]:=g/h; f:=f+g*a[j,i];
        end;
       {вычисление параметра K}
       hh:=f/(h+h);
       {преобразование матрицы A}
       for j:=0 to l do
        begin
         f:=a[i,j]; g:=e[j]-hh*f; e[j]:=g;
         for k:=0 to j do a[j,k]:=a[j,k] - f*e[k] - g*a[i,k];
        end;
      end
      else
       begin
        e[i]:=f; h:=0.0;
       end;
    d[i]:=h;
  end;
 d[0]:=0.0; e[0]:=0.0;
 {накопление матриц преобразования}
 for i:=0 to n do
  begin
   l:=i-1;
   if d[i]<>0 then
     for j:=0 to l do
      begin
       g:=0.;
       for k:=0 to l do g:=g + a[i,k]*a[k,j];
       for k:=0 to l do a[k,j]:=a[k,j] - g*a[k,i];
      end;
    d[i]:=a[i,i]; a[i,i]:=1.0;
    for j:=0 to l do
     begin
      a[i,j]:=0.0; a[j,i]:=0.0;
     end;
  end;
end;

function Sign(Arg1,Arg2 : double) : double;
begin
 if Arg2>=0 then Sign:=abs(Arg1) else Sign:=-abs(Arg1);
end;

function pythag(a,b : double) : double;
var absa,absb : double;
begin
 absa:=abs(a);
 absb:=abs(b);
 if absa>absb then pythag:=absa*sqrt(1+sqr(absb/absa)) else
  if absb=0. then pythag:=0. else
    pythag:=absb*sqrt(1+sqr(absa/absb));
end;

procedure tqli2(n,maxiter : integer; var z : tmatrixDouble; var d,e : tvector; var err : integer);
var i,iter,k,l,m : integer;
    b,c,dd,f,g,p,r,s : double;
label l1,l2;
begin
 dec(n);
 for i:=1 to n do e[i-1]:=e[i];
 e[n]:=0;
 for l:=0 to n do
  begin
   iter:=0;
l1:
   for m:=l to n-1 do
     begin
      dd:=abs(d[m])+abs(d[m+1]);
      if abs(e[m])+dd=dd then goto l2;
     end;
   m:=n;
l2:
   if m<>l then
    begin
     if iter=maxiter then begin
                     err:=-1; exit;
                          end;
     inc(iter);
     g:=(d[l+1]-d[l])/(2.*e[l]);
     r:=pythag(g,1);
     g:=d[m]-d[l]+e[l]/(g+sign(r,g));
     s:=1.; c:=1.; p:=0.;
     for i:=m-1 downto l do
      begin
       f:=s*e[i]; b:=c*e[i];
       r:=pythag(f,g);
       e[i+1]:=r;
       if r=0. then
         begin
          d[i+1]:=d[i+1]-p;
          e[m]:=0.;
          goto l1;
         end;
       s:=f/r; c:=g/r;
       g:=d[i+1]-p;
       r:=(d[i]-g)*s+2.*c*b;
       p:=s*r;
       d[i+1]:=g+p;
       g:=c*r-b;
       for k:=0 to n do
         begin
          f:=z[k,i+1];
          z[k,i+1]:=s*z[k,i]+c*f;
          z[k,i]:=c*z[k,i]-s*f;
         end;
      end;
     d[l]:=d[l]-p; e[l]:=g; e[m]:=0.; goto l1;
    end;
  end;
  err:=0;
end;


end.

