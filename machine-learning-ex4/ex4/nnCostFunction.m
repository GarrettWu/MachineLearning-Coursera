function [J grad] = nnCostFunction(nn_params, ...
                                   input_layer_size, ...
                                   hidden_layer_size, ...
                                   num_labels, ...
                                   X, y, lambda)
%NNCOSTFUNCTION Implements the neural network cost function for a two layer
%neural network which performs classification
%   [J grad] = NNCOSTFUNCTON(nn_params, hidden_layer_size, num_labels, ...
%   X, y, lambda) computes the cost and gradient of the neural network. The
%   parameters for the neural network are "unrolled" into the vector
%   nn_params and need to be converted back into the weight matrices. 
% 
%   The returned parameter grad should be a "unrolled" vector of the
%   partial derivatives of the neural network.
%

% Reshape nn_params back into the parameters Theta1 and Theta2, the weight matrices
% for our 2 layer neural network
Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                 hidden_layer_size, (input_layer_size + 1));

Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                 num_labels, (hidden_layer_size + 1));

% Setup some useful variables
m = size(X, 1);
         
% You need to return the following variables correctly 
J = 0;
Theta1_grad = zeros(size(Theta1));
Theta2_grad = zeros(size(Theta2));

% ====================== YOUR CODE HERE ======================
% Instructions: You should complete the code by working through the
%               following parts.
%
% Part 1: Feedforward the neural network and return the cost in the
%         variable J. After implementing Part 1, you can verify that your
%         cost function computation is correct by verifying the cost
%         computed in ex4.m
%
% Part 2: Implement the backpropagation algorithm to compute the gradients
%         Theta1_grad and Theta2_grad. You should return the partial derivatives of
%         the cost function with respect to Theta1 and Theta2 in Theta1_grad and
%         Theta2_grad, respectively. After implementing Part 2, you can check
%         that your implementation is correct by running checkNNGradients
%
%         Note: The vector y passed into the function is a vector of labels
%               containing values from 1..K. You need to map this vector into a 
%               binary vector of 1's and 0's to be used with the neural network
%               cost function.
%
%         Hint: We recommend implementing backpropagation using a for-loop
%               over the training examples if you are implementing it for the 
%               first time.
%
% Part 3: Implement regularization with the cost function and gradients.
%
%         Hint: You can implement this around the code for
%               backpropagation. That is, you can compute the gradients for
%               the regularization separately and then add them to Theta1_grad
%               and Theta2_grad from Part 2.
%

a1 = [ones(m, 1) X];            % 5000*401

a2 = sigmoid(a1 * Theta1');     % 5000*401 * 401*25 = 5000*25
a2 = [ones(size(a2, 1), 1) a2]; % 5000*26

h = sigmoid(a2 * Theta2');      % 5000*26 * 26*10 = 5000*10

yMod = zeros(size(h));          % 5000*10

for i = 1:size(yMod, 1)
    yMod(i, y(i)) = 1;
end

J = sum( sum( -yMod .* log(h) - (1 - yMod) .* log(1 - h) ) ) / m;

% regularized

Theta1Mod = Theta1(:, 2:size(Theta1, 2));
Theta2Mod = Theta2(:, 2:size(Theta2, 2));

J = J + (sum(sum(Theta1Mod .^ 2)) + sum(sum(Theta2Mod .^ 2))) * lambda / 2 / m;

% grad
DELTA_1 = zeros(size(Theta1_grad));
DELTA_2 = zeros(size(Theta2_grad));

for t = 1:m
    % step 1
    a_1 = [1; X(t, :)'];                    % 401*1
    z_2 = Theta1 * a_1;                     % 25*1
    a_2 = [1; sigmoid(z_2)];                % 26*1
    z_3 = Theta2 * a_2;                     % 10*1
    a_3 = sigmoid(z_3);                     % 10*1

    % step 2
%     yy = ([1:num_labels]==y(t))';
    delta_3 = a_3 - yMod(t, :)';            % 10*1
    
    % step 3
    delta_2 = (Theta2' * delta_3) .* [1; sigmoidGradient(z_2)];   % 26*10 * 10*1 = 26*1
    delta_2 = delta_2(2:end);               % 25*1
    
    % step 4
    DELTA_2 = DELTA_2 + delta_3 * a_2';
    DELTA_1 = DELTA_1 + delta_2 * a_1';

end

% step 5
Theta1_grad = (1/m) * DELTA_1 + (lambda/m) * [zeros(size(Theta1, 1), 1) Theta1(:,2:end)];
Theta2_grad = (1/m) * DELTA_2 + (lambda/m) * [zeros(size(Theta2, 1), 1) Theta2(:,2:end)];


% -------------------------------------------------------------

% =========================================================================

% Unroll gradients
grad = [Theta1_grad(:) ; Theta2_grad(:)];


end
