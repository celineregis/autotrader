module Optimizer

	def mini
		mini_test=Minimization::GoldenSection.new(-1000,20000  , proc {|x| (x+1)**2})
		mini_test.expected=1.5  # Expected value
		mini_test.iterate
		mini_test.x_minimum
	end

end