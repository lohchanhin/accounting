// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_category.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BudgetCategoryAdapter extends TypeAdapter<BudgetCategory> {
  @override
  final int typeId = 0;

  @override
  BudgetCategory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BudgetCategory(
      id: fields[0] as String?,
      name: fields[1] as String,
      icon: fields[2] as IconData,
      isExpense: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, BudgetCategory obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.icon)
      ..writeByte(3)
      ..write(obj.isExpense);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BudgetCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
