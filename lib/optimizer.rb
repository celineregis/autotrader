module Optimizer

	def optimizeTwoWay(stake_outcome_1, stake_outcome_2, reference_outcome_1, overound)
		reference_outcome_1 = reference_outcome_1.to_f
		reference_outcome_2=1/(1-1/reference_outcome_1)
  		stake_share_outcome_1=stake_outcome_1.to_f/(stake_outcome_1.to_f+stake_outcome_2.to_f)
  		stake_share_outcome_2=1-stake_share_outcome_1
		
		optimizer=Minimization::GoldenSection.new(
			(1/(1+overound-1/reference_outcome_2)), #lower
			reference_outcome_1, 					 #upper
			proc {|x| stake_share_outcome_1*x/reference_outcome_1+stake_share_outcome_2*(1/(1+overound-1/x))/reference_outcome_2}
		)
		optimizer.expected=reference_outcome_1/(1+overound) # Expected value
		optimizer.iterate
		optimizer.x_minimum
	end

	def optimizeThree
		rexp = $R.convert "1+1"
		puts rexp.to_ruby
	end
end