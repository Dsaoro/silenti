import 'package:flutter/foundation.dart';
import 'package:silenti/application/shared/base_use_case.dart';
import 'package:silenti/application/shared/handle_result.dart';
import 'package:silenti/core/models/operation.dart';
import 'package:silenti/infraestructure/storage/operation_dao.dart';
// import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class GetOperations extends BaseUseCase {
  GetOperations() : super("GetOperations");

  Future<HandleResult<List<Operation>>> byFinancialAsset(int assetId) async {
    HandleResult<List<Operation>> result = HandleResult<List<Operation>>();
    OperationDAO dao = OperationDAO();
    List<Operation> operations = [];
    try {
      await dao.getOperationsByAssetId(assetId).then((value) {
        for (var element in value) {
          operations.add(Operation.fromMap(element));
        }
        return operations;
      });
    } catch (e) {
      result.setError(e.toString());
      return result;
    }
    if (operations.isNotEmpty) {
      result.setData(operations);
    } else {
      result.setError("No operations found");
    }
    return result;
  }

  Future<HandleResult<List<Operation>>> byFinancialAssetLimited(int assetId,
      {int? limit}) async {
    HandleResult<List<Operation>> result = HandleResult<List<Operation>>();
    OperationDAO dao = OperationDAO();
    List<Operation> operations = [];
    try {
      await dao
          .getOperationsByAssetIdLimited(assetId, limit: limit)
          .then((value) {
        for (var element in value) {
          operations.add(Operation.fromMap(element));
        }
        return operations;
      });
    } catch (e) {
      result.setError(e.toString());
      return result;
    }
    if (operations.isNotEmpty) {
      result.setData(operations);
    } else {
      result.setError("No operations found");
    }
    return result;
  }

  Future<HandleResult<List<Operation>>> byBudgetCategoryLimited(int categoryId,
      {int? limit}) async {
    HandleResult<List<Operation>> result = HandleResult<List<Operation>>();
    OperationDAO dao = OperationDAO();
    List<Operation> operations = [];
    try {
      await dao
          .getOperationsByBudgetCategoryLimited(categoryId, limit: limit)
          .then((value) {
        for (var element in value) {
          operations.add(Operation.fromMap(element));
        }
        return operations;
      });
    } catch (e) {
      result.setError(e.toString());
      return result;
    }
    if (operations.isNotEmpty) {
      result.setData(operations);
    } else {
      result.setError("No operations found");
    }
    return result;
  }

  Future<HandleResult<List<Operation>>> getLastOperations(
      {required int limit}) async {
    HandleResult<List<Operation>> result = HandleResult<List<Operation>>();
    OperationDAO dao = OperationDAO();
    List<Operation> operations = [];
    try {
      await dao.getOperationsLimited(limit: limit).then((value) {
        for (var element in value) {
          operations.add(Operation.fromMap(element));
        }
        return operations;
      });
    } catch (e, stacktrace) {
      result.setError(e.toString());
      if (kDebugMode) {
        print(stacktrace);
      }
      return result;
    }
    if (operations.isNotEmpty) {
      result.setData(operations);
    } else {
      result.setError("No operations found");
    }
    return result;
  }

  Future<HandleResult<double>> getSpentAmountByCategoryAndMonth(
      int categoryId, int month, int year) async {
    HandleResult<double> result = HandleResult<double>();
    OperationDAO dao = OperationDAO();
    try {
      double spent =
          await dao.getSpentAmountByCategoryAndMonth(categoryId, month, year);
      result.setData(spent);
    } catch (e) {
      result.setError(e.toString());
    }
    return result;
  }
}
