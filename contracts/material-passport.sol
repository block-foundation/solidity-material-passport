// SPDX-License-Identifier: Apache-2.0


// Copyright 2023 Stichting Block Foundation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.


pragma solidity ^0.8.19;


contract MaterialPassport {
    struct Material {
        string name;
        string origin;
        string manufacturer;
        string description;
        uint expirationDate;
        bool isRecyclable;
        string materialType;
        string lifecycle;
    }

    // This creates an array with all materials
    Material[] public materials;

    // This creates a mapping from IDs to owners
    mapping(uint => address) public materialOwners;

    // This creates a mapping from owners to their balances
    mapping(address => uint) public balances;

    // This checks if the function caller is the owner of the material
    modifier onlyOwner(uint _materialId) {
        require(materialOwners[_materialId] == msg.sender, "You are not the owner of this material");
        _;
    }

    // This creates an event that is triggered whenever a material is registered
    event MaterialRegistered(uint materialId, address owner, string name, string origin, string manufacturer, string description, uint expirationDate, bool isRecyclable, string materialType, string lifecycle);
    
    // This creates an event that is triggered whenever a material is recycled
    event MaterialRecycled(uint materialId, address recycler);
    
    // This creates an event that is triggered whenever ownership of a material is transferred
    event MaterialTransferred(uint materialId, address from, address to);

    // Registers a new material
    function registerMaterial(string memory _name, string memory _origin, string memory _manufacturer, string memory _description, uint _expirationDate, bool _isRecyclable, string memory _materialType, string memory _lifecycle) public {
        uint id = materials.length;
        materials.push(Material(_name, _origin, _manufacturer, _description, _expirationDate, _isRecyclable, _materialType, _lifecycle));
        materialOwners[id] = msg.sender;
        emit MaterialRegistered(id, msg.sender, _name, _origin, _manufacturer, _description, _expirationDate, _isRecyclable, _materialType, _lifecycle);
    }

    // Transfers ownership of a material
    function transferMaterial(uint _materialId, address _newOwner) public onlyOwner(_materialId) {
        materialOwners[_materialId] = _newOwner;
        emit MaterialTransferred(_materialId, msg.sender, _newOwner);
    }
    
    // Recycles a material and rewards the recycler
    function recycleMaterial(uint _materialId) public onlyOwner(_materialId) {
        require(materials[_materialId].isRecyclable, "This material is not recyclable");
        require(block.timestamp >= materials[_materialId].expirationDate, "This material has not yet expired");
        
        // We mark the material as recycled by setting the owner to the zero address
        materialOwners[_materialId] = address(0);
        // Reward the recycler
        balances[msg.sender]++;
        emit MaterialRecycled(_materialId, msg.sender);
    }
    
    // Update the lifecycle of a material
    function updateLifecycle(uint _materialId, string memory _lifecycle) public onlyOwner(_materialId) {
        materials[_materialId].lifecycle = _lifecycle;
    }

    // Update the properties of a material
    function updateMaterialProperties(uint _materialId, string memory _name, string memory _origin, string memory _manufacturer, string memory _description, uint _expirationDate, bool _isRecyclable, string memory _materialType) public onlyOwner(_materialId) {
        Material storage material = materials[_materialId];
        material.name = _name;
        material.origin = _origin;
        material.manufacturer = _manufacturer;
        material.description = _description;
        material.expirationDate = _expirationDate;
        material.isRecyclable = _isRecyclable;
        material.materialType = _materialType;
    }

    // Check balance of the user
    function checkBalance() public view returns (uint) {
        return balances[msg.sender];
    }
}
