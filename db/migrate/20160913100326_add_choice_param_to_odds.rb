
class AddChoiceParamToOdds < ActiveRecord::Migration[5.0]
  def change
    add_column :odds, :choice_param, :string
  end
end
