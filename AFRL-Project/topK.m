function [ b ] = topK( a,k, zone )
%Finds top k elements in matrix a zone/non-zone way
% zone=0 - top k in matrix a
% zone=1 - top k in each zone
    if (zone==0)
        temp=sort(a(:),'descend');
        b=(a>=temp(k)).*a;
    elseif (zone==1)
        ir = ceil(size(a,1)/2);
        ic = ceil(size(a,2)/3);
        z1 = a(1:ir,1:ic);
        z2 = a(1:ir,ic+1:2*ic);
        z3 = a(1:ir,2*ic+1:size(a,2));
        z4 = a(ir+1:size(a,1),1:ic);
        z5 = a(ir+1:size(a,1),ic+1:2*ic);
        z6 = a(ir+1:size(a,1),2*ic+1:size(a,2));

        temp=sort(z1(:),'descend');
        bz1=(z1>=temp(k)).*z1;

        temp=sort(z2(:),'descend');
        bz2=(z2>=temp(k)).*z2;

        temp=sort(z3(:),'descend');
        bz3=(z3>=temp(k)).*z3;

        temp=sort(z4(:),'descend');
        bz4=(z4>=temp(k)).*z4;

        temp=sort(z5(:),'descend');
        bz5=(z5>=temp(k)).*z5;

        temp=sort(z6(:),'descend');
        bz6=(z6>=temp(k)).*z6;

        b = [bz1,bz2,bz3;bz4,bz5,bz6];
    end
end

