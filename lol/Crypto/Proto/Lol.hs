{-# LANGUAGE BangPatterns, DeriveDataTypeable, DeriveGeneric, FlexibleInstances, MultiParamTypeClasses #-}
{-# OPTIONS_GHC  -fno-warn-unused-imports #-}
module Crypto.Proto.Lol (protoInfo, fileDescriptorProto) where
import Prelude ((+), (/))
import qualified Prelude as Prelude'
import qualified Data.Typeable as Prelude'
import qualified GHC.Generics as Prelude'
import qualified Data.Data as Prelude'
import qualified Text.ProtocolBuffers.Header as P'
import Text.DescriptorProtos.FileDescriptorProto (FileDescriptorProto)
import Text.ProtocolBuffers.Reflections (ProtoInfo)
import qualified Text.ProtocolBuffers.WireMessage as P' (wireGet,getFromBS)

protoInfo :: ProtoInfo
protoInfo
 = Prelude'.read
    "ProtoInfo {protoMod = ProtoName {protobufName = FIName \".crypto.proto.lol\", haskellPrefix = [], parentModule = [MName \"Crypto\",MName \"Proto\"], baseName = MName \"Lol\"}, protoFilePath = [\"Crypto\",\"Proto\",\"Lol.hs\"], protoSource = \"Lol.proto\", extensionKeys = fromList [], messages = [DescriptorInfo {descName = ProtoName {protobufName = FIName \".crypto.proto.lol.LinearRq\", haskellPrefix = [], parentModule = [MName \"Crypto\",MName \"Proto\",MName \"Lol\"], baseName = MName \"LinearRq\"}, descFilePath = [\"Crypto\",\"Proto\",\"Lol\",\"LinearRq.hs\"], isGroup = False, fields = fromList [FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".crypto.proto.lol.LinearRq.e\", haskellPrefix' = [], parentModule' = [MName \"Crypto\",MName \"Proto\",MName \"Lol\",MName \"LinearRq\"], baseName' = FName \"e\", baseNamePrefix' = \"\"}, fieldNumber = FieldId {getFieldId = 1}, wireTag = WireTag {getWireTag = 8}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = True, canRepeat = False, mightPack = False, typeCode = FieldType {getFieldType = 13}, typeName = Nothing, hsRawDefault = Nothing, hsDefault = Nothing},FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".crypto.proto.lol.LinearRq.r\", haskellPrefix' = [], parentModule' = [MName \"Crypto\",MName \"Proto\",MName \"Lol\",MName \"LinearRq\"], baseName' = FName \"r\", baseNamePrefix' = \"\"}, fieldNumber = FieldId {getFieldId = 2}, wireTag = WireTag {getWireTag = 16}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = True, canRepeat = False, mightPack = False, typeCode = FieldType {getFieldType = 13}, typeName = Nothing, hsRawDefault = Nothing, hsDefault = Nothing},FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".crypto.proto.lol.LinearRq.coeffs\", haskellPrefix' = [], parentModule' = [MName \"Crypto\",MName \"Proto\",MName \"Lol\",MName \"LinearRq\"], baseName' = FName \"coeffs\", baseNamePrefix' = \"\"}, fieldNumber = FieldId {getFieldId = 3}, wireTag = WireTag {getWireTag = 26}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = False, canRepeat = True, mightPack = False, typeCode = FieldType {getFieldType = 11}, typeName = Just (ProtoName {protobufName = FIName \".crypto.proto.lol.RqProduct\", haskellPrefix = [], parentModule = [MName \"Crypto\",MName \"Proto\",MName \"Lol\"], baseName = MName \"RqProduct\"}), hsRawDefault = Nothing, hsDefault = Nothing}], descOneofs = fromList [], keys = fromList [], extRanges = [], knownKeys = fromList [], storeUnknown = False, lazyFields = False, makeLenses = False},DescriptorInfo {descName = ProtoName {protobufName = FIName \".crypto.proto.lol.R\", haskellPrefix = [], parentModule = [MName \"Crypto\",MName \"Proto\",MName \"Lol\"], baseName = MName \"R\"}, descFilePath = [\"Crypto\",\"Proto\",\"Lol\",\"R.hs\"], isGroup = False, fields = fromList [FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".crypto.proto.lol.R.m\", haskellPrefix' = [], parentModule' = [MName \"Crypto\",MName \"Proto\",MName \"Lol\",MName \"R\"], baseName' = FName \"m\", baseNamePrefix' = \"\"}, fieldNumber = FieldId {getFieldId = 1}, wireTag = WireTag {getWireTag = 8}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = True, canRepeat = False, mightPack = False, typeCode = FieldType {getFieldType = 13}, typeName = Nothing, hsRawDefault = Nothing, hsDefault = Nothing},FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".crypto.proto.lol.R.xs\", haskellPrefix' = [], parentModule' = [MName \"Crypto\",MName \"Proto\",MName \"Lol\",MName \"R\"], baseName' = FName \"xs\", baseNamePrefix' = \"\"}, fieldNumber = FieldId {getFieldId = 2}, wireTag = WireTag {getWireTag = 16}, packedTag = Just (WireTag {getWireTag = 16},WireTag {getWireTag = 18}), wireTagLength = 1, isPacked = False, isRequired = False, canRepeat = True, mightPack = True, typeCode = FieldType {getFieldType = 18}, typeName = Nothing, hsRawDefault = Nothing, hsDefault = Nothing}], descOneofs = fromList [], keys = fromList [], extRanges = [], knownKeys = fromList [], storeUnknown = False, lazyFields = False, makeLenses = False},DescriptorInfo {descName = ProtoName {protobufName = FIName \".crypto.proto.lol.Rq\", haskellPrefix = [], parentModule = [MName \"Crypto\",MName \"Proto\",MName \"Lol\"], baseName = MName \"Rq\"}, descFilePath = [\"Crypto\",\"Proto\",\"Lol\",\"Rq.hs\"], isGroup = False, fields = fromList [FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".crypto.proto.lol.Rq.m\", haskellPrefix' = [], parentModule' = [MName \"Crypto\",MName \"Proto\",MName \"Lol\",MName \"Rq\"], baseName' = FName \"m\", baseNamePrefix' = \"\"}, fieldNumber = FieldId {getFieldId = 1}, wireTag = WireTag {getWireTag = 8}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = True, canRepeat = False, mightPack = False, typeCode = FieldType {getFieldType = 13}, typeName = Nothing, hsRawDefault = Nothing, hsDefault = Nothing},FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".crypto.proto.lol.Rq.q\", haskellPrefix' = [], parentModule' = [MName \"Crypto\",MName \"Proto\",MName \"Lol\",MName \"Rq\"], baseName' = FName \"q\", baseNamePrefix' = \"\"}, fieldNumber = FieldId {getFieldId = 2}, wireTag = WireTag {getWireTag = 16}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = True, canRepeat = False, mightPack = False, typeCode = FieldType {getFieldType = 4}, typeName = Nothing, hsRawDefault = Nothing, hsDefault = Nothing},FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".crypto.proto.lol.Rq.xs\", haskellPrefix' = [], parentModule' = [MName \"Crypto\",MName \"Proto\",MName \"Lol\",MName \"Rq\"], baseName' = FName \"xs\", baseNamePrefix' = \"\"}, fieldNumber = FieldId {getFieldId = 3}, wireTag = WireTag {getWireTag = 24}, packedTag = Just (WireTag {getWireTag = 24},WireTag {getWireTag = 26}), wireTagLength = 1, isPacked = False, isRequired = False, canRepeat = True, mightPack = True, typeCode = FieldType {getFieldType = 18}, typeName = Nothing, hsRawDefault = Nothing, hsDefault = Nothing}], descOneofs = fromList [], keys = fromList [], extRanges = [], knownKeys = fromList [], storeUnknown = False, lazyFields = False, makeLenses = False},DescriptorInfo {descName = ProtoName {protobufName = FIName \".crypto.proto.lol.Kq\", haskellPrefix = [], parentModule = [MName \"Crypto\",MName \"Proto\",MName \"Lol\"], baseName = MName \"Kq\"}, descFilePath = [\"Crypto\",\"Proto\",\"Lol\",\"Kq.hs\"], isGroup = False, fields = fromList [FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".crypto.proto.lol.Kq.m\", haskellPrefix' = [], parentModule' = [MName \"Crypto\",MName \"Proto\",MName \"Lol\",MName \"Kq\"], baseName' = FName \"m\", baseNamePrefix' = \"\"}, fieldNumber = FieldId {getFieldId = 1}, wireTag = WireTag {getWireTag = 8}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = True, canRepeat = False, mightPack = False, typeCode = FieldType {getFieldType = 13}, typeName = Nothing, hsRawDefault = Nothing, hsDefault = Nothing},FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".crypto.proto.lol.Kq.q\", haskellPrefix' = [], parentModule' = [MName \"Crypto\",MName \"Proto\",MName \"Lol\",MName \"Kq\"], baseName' = FName \"q\", baseNamePrefix' = \"\"}, fieldNumber = FieldId {getFieldId = 2}, wireTag = WireTag {getWireTag = 16}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = True, canRepeat = False, mightPack = False, typeCode = FieldType {getFieldType = 4}, typeName = Nothing, hsRawDefault = Nothing, hsDefault = Nothing},FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".crypto.proto.lol.Kq.xs\", haskellPrefix' = [], parentModule' = [MName \"Crypto\",MName \"Proto\",MName \"Lol\",MName \"Kq\"], baseName' = FName \"xs\", baseNamePrefix' = \"\"}, fieldNumber = FieldId {getFieldId = 3}, wireTag = WireTag {getWireTag = 25}, packedTag = Just (WireTag {getWireTag = 25},WireTag {getWireTag = 26}), wireTagLength = 1, isPacked = False, isRequired = False, canRepeat = True, mightPack = True, typeCode = FieldType {getFieldType = 1}, typeName = Nothing, hsRawDefault = Nothing, hsDefault = Nothing}], descOneofs = fromList [], keys = fromList [], extRanges = [], knownKeys = fromList [], storeUnknown = False, lazyFields = False, makeLenses = False},DescriptorInfo {descName = ProtoName {protobufName = FIName \".crypto.proto.lol.RqProduct\", haskellPrefix = [], parentModule = [MName \"Crypto\",MName \"Proto\",MName \"Lol\"], baseName = MName \"RqProduct\"}, descFilePath = [\"Crypto\",\"Proto\",\"Lol\",\"RqProduct.hs\"], isGroup = False, fields = fromList [FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".crypto.proto.lol.RqProduct.rqlist\", haskellPrefix' = [], parentModule' = [MName \"Crypto\",MName \"Proto\",MName \"Lol\",MName \"RqProduct\"], baseName' = FName \"rqlist\", baseNamePrefix' = \"\"}, fieldNumber = FieldId {getFieldId = 1}, wireTag = WireTag {getWireTag = 10}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = False, canRepeat = True, mightPack = False, typeCode = FieldType {getFieldType = 11}, typeName = Just (ProtoName {protobufName = FIName \".crypto.proto.lol.Rq\", haskellPrefix = [], parentModule = [MName \"Crypto\",MName \"Proto\",MName \"Lol\"], baseName = MName \"Rq\"}), hsRawDefault = Nothing, hsDefault = Nothing}], descOneofs = fromList [], keys = fromList [], extRanges = [], knownKeys = fromList [], storeUnknown = False, lazyFields = False, makeLenses = False},DescriptorInfo {descName = ProtoName {protobufName = FIName \".crypto.proto.lol.KqProduct\", haskellPrefix = [], parentModule = [MName \"Crypto\",MName \"Proto\",MName \"Lol\"], baseName = MName \"KqProduct\"}, descFilePath = [\"Crypto\",\"Proto\",\"Lol\",\"KqProduct.hs\"], isGroup = False, fields = fromList [FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".crypto.proto.lol.KqProduct.kqlist\", haskellPrefix' = [], parentModule' = [MName \"Crypto\",MName \"Proto\",MName \"Lol\",MName \"KqProduct\"], baseName' = FName \"kqlist\", baseNamePrefix' = \"\"}, fieldNumber = FieldId {getFieldId = 1}, wireTag = WireTag {getWireTag = 10}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = False, canRepeat = True, mightPack = False, typeCode = FieldType {getFieldType = 11}, typeName = Just (ProtoName {protobufName = FIName \".crypto.proto.lol.Kq\", haskellPrefix = [], parentModule = [MName \"Crypto\",MName \"Proto\",MName \"Lol\"], baseName = MName \"Kq\"}), hsRawDefault = Nothing, hsDefault = Nothing}], descOneofs = fromList [], keys = fromList [], extRanges = [], knownKeys = fromList [], storeUnknown = False, lazyFields = False, makeLenses = False},DescriptorInfo {descName = ProtoName {protobufName = FIName \".crypto.proto.lol.TypeRep\", haskellPrefix = [], parentModule = [MName \"Crypto\",MName \"Proto\",MName \"Lol\"], baseName = MName \"TypeRep\"}, descFilePath = [\"Crypto\",\"Proto\",\"Lol\",\"TypeRep.hs\"], isGroup = False, fields = fromList [FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".crypto.proto.lol.TypeRep.a\", haskellPrefix' = [], parentModule' = [MName \"Crypto\",MName \"Proto\",MName \"Lol\",MName \"TypeRep\"], baseName' = FName \"a\", baseNamePrefix' = \"\"}, fieldNumber = FieldId {getFieldId = 1}, wireTag = WireTag {getWireTag = 8}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = True, canRepeat = False, mightPack = False, typeCode = FieldType {getFieldType = 4}, typeName = Nothing, hsRawDefault = Nothing, hsDefault = Nothing},FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".crypto.proto.lol.TypeRep.b\", haskellPrefix' = [], parentModule' = [MName \"Crypto\",MName \"Proto\",MName \"Lol\",MName \"TypeRep\"], baseName' = FName \"b\", baseNamePrefix' = \"\"}, fieldNumber = FieldId {getFieldId = 2}, wireTag = WireTag {getWireTag = 16}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = True, canRepeat = False, mightPack = False, typeCode = FieldType {getFieldType = 4}, typeName = Nothing, hsRawDefault = Nothing, hsDefault = Nothing}], descOneofs = fromList [], keys = fromList [], extRanges = [], knownKeys = fromList [], storeUnknown = False, lazyFields = False, makeLenses = False}], enums = [], oneofs = [], knownKeyMap = fromList []}"

fileDescriptorProto :: FileDescriptorProto
fileDescriptorProto
 = P'.getFromBS (P'.wireGet 11)
    (P'.pack
      "\223\STX\n\tLol.proto\DC2\DLEcrypto.proto.lol\"M\n\bLinearRq\DC2\t\n\SOHe\CAN\SOH \STX(\r\DC2\t\n\SOHr\CAN\STX \STX(\r\DC2+\n\ACKcoeffs\CAN\ETX \ETX(\v2\ESC.crypto.proto.lol.RqProduct\"\SUB\n\SOHR\DC2\t\n\SOHm\CAN\SOH \STX(\r\DC2\n\n\STXxs\CAN\STX \ETX(\DC2\"&\n\STXRq\DC2\t\n\SOHm\CAN\SOH \STX(\r\DC2\t\n\SOHq\CAN\STX \STX(\EOT\DC2\n\n\STXxs\CAN\ETX \ETX(\DC2\"&\n\STXKq\DC2\t\n\SOHm\CAN\SOH \STX(\r\DC2\t\n\SOHq\CAN\STX \STX(\EOT\DC2\n\n\STXxs\CAN\ETX \ETX(\SOH\"1\n\tRqProduct\DC2$\n\ACKrqlist\CAN\SOH \ETX(\v2\DC4.crypto.proto.lol.Rq\"1\n\tKqProduct\DC2$\n\ACKkqlist\CAN\SOH \ETX(\v2\DC4.crypto.proto.lol.Kq\"\US\n\aTypeRep\DC2\t\n\SOHa\CAN\SOH \STX(\EOT\DC2\t\n\SOHb\CAN\STX \STX(\EOT")