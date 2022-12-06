clear
%Type of problem -> either "Maximise" or "Minimise"
problem = "Maximise";

%Number of initial variables in the problem
init_vars = 4;
syms x [1,init_vars]

%Minimise Problem (Pass) -> SOL:Alternate Optima, 16
z = -4*x1 + 6*x2 - 2*x3 + 4*x4;
constraints = [x1 + 2*x2 - 2*x3 + 4*x4 <= 40,...
    2*x1 - x2 + x3 + 2*x4 <= 8,...
    4*x1 - 2*x2 + x3 - x4 <= 10];

[solution,create_solution] = Code_SimplexMethod(problem,init_vars,z,constraints);

if create_solution == "True"
    %Format solutions
    disp("Solutions:")
    disp(solution.op_sol)
    disp(solution.z)
else
    disp(solution)
end