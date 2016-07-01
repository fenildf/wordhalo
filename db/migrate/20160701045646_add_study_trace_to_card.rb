class AddStudyTraceToCard < ActiveRecord::Migration
  def change
    add_column :cards, :study_trace, :string
    add_column :cards, :study_state, :integer
  end
end
