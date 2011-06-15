#helpers:
def should_be_a_subset(superset, records_selected_by_scope, &condition)
  flunk "Your superset is empty" if superset.empty?
  flunk "Your scope did not select any records" if records_selected_by_scope.empty?

  records_selected_by_block, records_excluded_by_block = superset.partition(&condition)
  flunk "Your test condition did not select any records" if records_selected_by_block.empty?
  flunk "Your test condition did not exclude any records" if records_excluded_by_block.empty?

  records_selected_by_scope.map(&:id).should =~ records_selected_by_block.map(&:id)
end

