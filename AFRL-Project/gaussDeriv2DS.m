function [ Gx, Gy ] = gaussDeriv2DS(  sigma, hsize, range  )
%  Second derivative gaussian
for i = 1:hsize
    for j = 1:hsize
        x = i-range-1;
        y = j-range-1;
        t_1=(x^2/(sqrt(2*pi)*(sigma^5)))-(1/(sqrt(2*pi)*(sigma^3)));
        t_2=exp(-(x^2+y^2)/(2*sigma*sigma));
        Gx(j,i) = t_1*t_2;
    end
end
%generate a 2-D Gaussian kernel along y direction
Gy=Gx';

end

