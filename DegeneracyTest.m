clear
%Type of problem -> either "Maximise" or "Minimise"
problem = "Maximise";

%Number of initial variables in the problem
init_vars = 2;
syms x [1,init_vars]

%Degenerancy Problem Test (Max) (Pass) SOL -> 18
z = 3*x1 + 9*x2;
constraints = [x1 + 4*x2 <= 8,...
    x1 + 2*x2 <= 4];

[solution,create_solution] = Code_SimplexMethod(problem,init_vars,z,constraints);

if create_solution == "True"
    %Format solutions
    disp("Solutions:")
    disp(solution.op_sol)
    disp(solution.z)
else
    disp(solution)
end