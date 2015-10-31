function enableOrDisableDivisionFactors(user_id){
	//$("form_expense_division_factor_" + user_id)
	if($("#form_expense_user_ids_" + user_id).prop('checked')){
		$("#form_expense_division_factor_" + user_id).prop('disabled', false);
	}else{
		$("#form_expense_division_factor_" + user_id).prop('disabled', true);
	}
}