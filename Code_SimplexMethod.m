function [solution,create_solution] = Code_SimplexMethod(problem,init_vars,z,constraints)

create_solution = "True";
infeasible = "False";
unbounded = "False";

%The m × n system of m equations Ax = b in n unknowns can be written as the sum from j=1 to n, Pj * xj = b
%Pj has m elements and is the jth column of the matrix A

num_iterations = 0;

x_init = (sym('x',[init_vars 1]));

if problem == "Minimise"
    z = z * -1;
end

%Number of equations = number of columns in 'constraints'
m = size(constraints,2);

%Number of variables
vars = symvar(constraints);
n = size(vars,2);

%Conditions that use the > or >= operator are internally rewritten using 
% the < or <= operator. Therefore, lhs returns the original right side. 
% For example, if lhs does not contain a variable, then 
% hasSymType(LHS,'variable') returns 0.
%Equations are all either '==','<=','>='

%create a row vector containing the indices of the variables used for the
%initial BFS
BFS_vars = zeros(1,m);

added_vars = 0;

new_slacksurplus = 0;
new_artificial = 0;
new_var = zeros(m,1);
new_art = zeros(m,1);
artificial_vars = [];
for i = 1:m
    %Check type of equation
    type = hasSymType(constraints(i),'eq');
    if type == 0
        %Check if new variable added
        added_vars = added_vars + 1;
        new_slacksurplus = new_slacksurplus + 1;
        LHS = lhs(constraints(i));
        is_variable = hasSymType(LHS,'variable');
        if is_variable == 0
            added_vars = added_vars + 1;
            % case -> '>='
            new_var(i,1) = -1;
            new_artificial = new_artificial + 1;
            new_art(i,1) = 1;
            artificial_vars = horzcat(artificial_vars,n+added_vars);
            BFS_vars(1,i) = n+added_vars;
        else
            % case -> '<='
            new_var(i,1) = +1;
            BFS_vars(1,i) = n+added_vars;
        end
    else
        added_vars = added_vars + 1;
        BFS_vars(1,i) = n+added_vars;
        new_artificial = new_artificial + 1;
        new_art(i,1) = 1;
        artificial_vars = horzcat(artificial_vars,n+added_vars);
    end
end

x_new = (sym('x',[n+new_slacksurplus+new_artificial 1]));
x_new_vars = 1:n+new_slacksurplus+new_artificial;
x_new_vars(:,1:init_vars) = [];

%Manipulate constraints
count = n+1;
for i = 1:m
    if new_var(i,1) == 1
        LHS = lhs(constraints(i));
        new_LHS = LHS + new_var(i,1)*x_new(count,1);
        constraints(i) = new_LHS == rhs(constraints(i));
        count = count + 1;
    end
    if new_var(i,1) == -1
        RHS = rhs(constraints(i));
        new_RHS = RHS + new_var(i,1)*x_new(count,1);
        constraints(i) = new_RHS == lhs(constraints(i));
        count = count + 1;
    end
    if new_art(i,1) == 1
        LHS = lhs(constraints(i));
        new_LHS = LHS + x_new(count,1);
        constraints(i) = new_LHS == rhs(constraints(i));
        count = count + 1;
    end
end

[A,b] = equationsToMatrix(constraints,x_new);

%n unknowns, m equations
n = n + new_slacksurplus+new_artificial;


%x -> all variables
x = x_new;
%x_new_vars -> new, added variables
%x_init -> initial variables

%cT -> coeffecients of z
cT = coeffs(z, fliplr(x.'));
if added_vars >= 1
    cT_temp = zeros(1,new_slacksurplus + new_artificial);
    cT = [cT,cT_temp];
end

B = zeros(size(BFS_vars,2),size(BFS_vars,2));

%Find the coeffeicents in cT of the columns used in B
cBT = zeros(1,size(BFS_vars,2));
for i = 1:size(BFS_vars,2)
    B(:,i) = A(:,BFS_vars(1,i));
    cBT(1,i) = cT(1,(BFS_vars(1,i)));
end

count = 1;
cJ_temp = 1:n;

%indices -> indexes of initial variables (no slack/surplus/artificial) same
%as the vars in nonbasic solution
indices = zeros(1,n-(new_slacksurplus+new_artificial));
for i = 1:n
    found_var = "False";
    for j = 1:size(BFS_vars,2)
        if cJ_temp(i) == BFS_vars(j)
            found_var = "True";
        end
    end
    if found_var == "False"
        indices(1,count) = cJ_temp(1,i);
        count = count+1;
    end
end

pJ = zeros(m,n-m);
cJ = zeros(1,size(indices,2));
for i = 1:size(indices,2)
    cJ(1,i) = cT(1,i);
    pJ(:,i) = A(:,i);
end

%xB -> refers to the columns of B, same as BFS_vars
xB = BFS_vars;
xB_vars = b;

z_new = cBT * xB_vars;

%Optimality condition
nonbasic = cBT*(inv(B))*pJ - cJ;
min_value = min(nonbasic);
%ITERATIONS
while min_value < 0

    entering_index = find(nonbasic==min(nonbasic(nonbasic<0)));
    entering_value = indices(1,entering_index);

    %Feasibility condition
    feasibility = (xB_vars)./(inv(B) * pJ(:,entering_index));
    
    %>=
    leaving_index = find(feasibility==min(feasibility(feasibility>=0)));
    %Check whether 2 or more values in feasibility are =
    if size(leaving_index,1) > 1
        leaving_index = leaving_index(1,1);
        disp("same")
    end

    leaving_value = BFS_vars(1,leaving_index);


    %Adjust indices array
    indices_temp = indices;
    for i = 1:size(indices,2)
        if indices(1,i) == entering_value
            indices_temp(1,i) = leaving_value;
        end
    end
    indices = sort(indices_temp);

    %change Pj and Cj
    for i = 1:size(indices,2)
        pJ(:,i) = A(:,indices(1,i));
        cJ(1,i) = cT(1,indices(1,i));
    end

    %swap BFS_vars around
    BFS_vars_swap_index = 0;
    BFS_vars_temp = BFS_vars;
    for i = 1:size(BFS_vars_temp,2)
        if BFS_vars(1,i) == leaving_value
            BFS_vars_temp(1,i) = entering_value;
            xB(1,i) = entering_value;
            BFS_vars_swap_index = i;
        end
    end
    BFS_vars = BFS_vars_temp;

    B(:,BFS_vars_swap_index) = A(:,BFS_vars(1,BFS_vars_swap_index));

    for i = 1:size(BFS_vars,2)
        cBT(1,i) = cT(1,(BFS_vars(1,i)));
    end

    xB_vars = inv(B)*b;
    z_new = cBT*xB_vars;

    %Optimality condition
    nonbasic = cBT*(inv(B))*pJ - cJ;
    min_value = min(nonbasic);
    

    num_iterations = num_iterations+1;
    
    
    %Check for unbounded solution
    unbounded = "True";
    for i = 1:size(nonbasic,2)
        if nonbasic(1,i) > 0
            unbounded = "False";
            break
        end
    end

end
%Check for infeasible solution
infeasible = "False";
if min_value >= 0
    for i = 1: size(BFS_vars,2)
        for j = 1:size(artificial_vars,2)
            if BFS_vars(1,i) == artificial_vars(1,j)
                infeasible = "True";
                %break
            end
        end
    end
end

%Check for alternate optima:
%If there is a zero in a nonbasic variable of the solution at the end of
%iterations then there are alternate optima
alternate_optima = "False";
alternate_optima_existed = "False";
if infeasible == "False" && unbounded == "False"
    for i = 1:size(nonbasic,2)
        if nonbasic(1,i) == 0
            alternate_optima = "True";
            alternate_op_var_index = i;

            %Save old solution
            solution_array_1 = cell(2, size(xB_vars,1));
            for i = 1:size(xB_vars,1)
                solution_array_1{1,i} = x_new(xB(1,i),1);
                solution_array_1{2,i} = xB_vars(i,1);
            end
            alternate_optima_existed = "True";
        end
    end
end

if alternate_optima == "True"   
    
    alternate_op_entering_var = indices(1,alternate_op_var_index);
    entering_value = alternate_op_entering_var;

    feasibility = (xB_vars)./(inv(B) * pJ(:,alternate_op_var_index));

    leaving_index = find(feasibility==min(feasibility(feasibility>0)));
    leaving_value = BFS_vars(1,leaving_index);

    %Adjust indices array
    indices_temp = indices;
    for i = 1:size(indices,2)
        if indices(1,i) == entering_value
            indices_temp(1,i) = leaving_value;
        end
    end
    indices = sort(indices_temp);

    %change Pj and Cj
    for i = 1:size(indices,2)
        pJ(:,i) = A(:,indices(1,i));
        cJ(1,i) = cT(1,indices(1,i));
    end

    %swap BFS_vars around
    BFS_vars_swap_index = 0;
    BFS_vars_temp = BFS_vars;
    for i = 1:size(BFS_vars_temp,2)
        if BFS_vars(1,i) == leaving_value
            BFS_vars_temp(1,i) = entering_value;
            xB(1,i) = entering_value;
            BFS_vars_swap_index = i;
        end
    end
    BFS_vars = BFS_vars_temp;

    B(:,BFS_vars_swap_index) = A(:,BFS_vars(1,BFS_vars_swap_index));

    for i = 1:size(BFS_vars,2)
        cBT(1,i) = cT(1,(BFS_vars(1,i)));
    end

    xB_vars = inv(B)*b;
    z_new = cBT*xB_vars;

    %Optimality condition
    nonbasic = cBT*(inv(B))*pJ - cJ;
    min_value = min(nonbasic);

    num_iterations = num_iterations+1;

    %Check for alternate optima:
    %If there is a zero in a nonbasic variable of the solution at the end of
    %iterations then there are alternate optima


%     alternate_optima = "False";
%     for i = 1:size(nonbasic,2)
%         if nonbasic(1,i) == 0
%             alternate_optima = "True";
%             alternate_op_var_index = i;
%         end
%     end

end

if unbounded == "True"
    create_solution = "False";
    solution = "There are no solutions because the system is unbounded.";
end
if infeasible == "True"
    create_solution = "False";
    solution = "There are no solutions because the system is infeasible.";
end

if create_solution == "True"
    %Disp solution
    solution = struct;

    solution_array = cell(2, size(xB_vars,1));
    for i = 1:size(xB_vars,1)
        solution_array{1,i} = x_new(xB(1,i),1);
        solution_array{2,i} = xB_vars(i,1);
    end

    if alternate_optima_existed == "True"
        disp("Alternate Optima Exist.")
        solution_array = [solution_array;cell(1,size(xB_vars,1));solution_array_1];
    end
    solution_z = cell(2,1);
    if problem == "Minimise"
        z_new = z_new *-1;
    end
    solution_z{1,1} = "z";
    solution_z{2,1} = z_new;

    solution.op_sol = solution_array;
    solution.z = solution_z;
    solution.iterations = num_iterations;

end

end