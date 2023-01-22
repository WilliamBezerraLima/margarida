import 'package:sqfentity_gen/sqfentity_gen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:sqfentity/sqfentity.dart';

part 'model.g.dart';

@SqfEntityBuilder(margaridaDbModel)
const margaridaDbModel = SqfEntityModel(
    modelName: 'MargaridaDbModel', // optional
    databaseName: 'margarida.db',
    databaseTables: [tablePlaylist, tableVideo, tableConfiguration],
    bundledDatabasePath: null);

const tableConfiguration = SqfEntityTable(
    tableName: 'tbconfiguration',
    primaryKeyName: 'id',
    primaryKeyType: PrimaryKeyType.integer_auto_incremental,
    useSoftDeleting: true,
    modelName: null,
    fields: [
      SqfEntityField('downloadpath', DbType.text),
      SqfEntityField('darkmode', DbType.bool),
      SqfEntityField('autoplay', DbType.bool),
    ]);

const tablePlaylist = SqfEntityTable(
    tableName: 'tbplaylist',
    primaryKeyName: 'id',
    primaryKeyType: PrimaryKeyType.integer_auto_incremental,
    useSoftDeleting: true,
    modelName: null,
    fields: [
      SqfEntityField('author', DbType.text),
      SqfEntityField('title', DbType.text),
      SqfEntityField('videoId', DbType.text),
      SqfEntityField('playlistId', DbType.text),
      SqfEntityField('thumbnail', DbType.text),
      SqfEntityField('thumbnailHigh', DbType.text),
      SqfEntityField('thumbnailLow', DbType.text),
      SqfEntityField('path', DbType.text),
    ]);

const tableVideo = SqfEntityTable(
    tableName: 'tbvideo',
    primaryKeyName: 'id',
    primaryKeyType: PrimaryKeyType.integer_auto_incremental,
    useSoftDeleting: true,
    fields: [
      SqfEntityField('videoId', DbType.text),
      SqfEntityField('author', DbType.text),
      SqfEntityField('title', DbType.text),
      SqfEntityField('duration', DbType.text),
      SqfEntityField('thumbnail', DbType.text),
      SqfEntityField('thumbnailHigh', DbType.text),
      SqfEntityField('thumbnailLow', DbType.text),
      SqfEntityField('path', DbType.text),
      SqfEntityFieldRelationship(
          parentTable: tablePlaylist,
          deleteRule: DeleteRule.CASCADE,
          defaultValue: '0',
          fieldName: "playlistId",
          isPrimaryKeyField: false),
    ]);
