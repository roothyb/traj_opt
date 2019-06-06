function residVal = residFunc(Z,D,N,a,b,x0)

T = Z(end);
X(N,2) = 0;
X(:,1) = Z(1:N);
X(:,2) = Z(N+1:2*N);

F(N,2) = 0;
    for i = 1:N
        F(i,:) = dynFunc(0,X(i,:),a,b)';
    end

mulFac = (2*pi/T);
residVal = reshape(D*X*mulFac-F,[2*N,1]);
residVal(end+1) = Z(1)-x0;
    
end