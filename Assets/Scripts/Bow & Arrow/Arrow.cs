using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Arrow : MonoBehaviour
{
    // damage that the arrow does if we implement an Health Script
    // private float m_damage;

    private float m_torque = 5f; 

    [SerializeField]
    private Rigidbody m_rigidBody;

    private string m_enemyTag;
        
    private bool m_Hit;

    private void Update()
    {
        transform.rotation = Quaternion.LookRotation(m_rigidBody.velocity);
    }

    public void SetEnemyTag(string enemyTag)
    {
        m_enemyTag = enemyTag;
    }

    /*
    public void Fly(Vector3 force)
    {
        m_rigidBody.isKinematic = false;
        m_rigidBody.AddForce(force, ForceMode.Impulse);
        m_rigidBody.AddTorque(m_torque * transform.right);
        transform.SetParent(null);
    }*/

    private void OnTriggerEnter(Collider other)
    {
        if (m_Hit) return;
        m_Hit = true; 

        if(other.CompareTag(m_enemyTag))
        {
            // fer mal al enemic
            print("Hit Enemy");
        }

        // si es vol que es quedi la fletxa encrustrada en l'objecte
        //m_rigidBody.velocity = Vector3.zero;
        //m_rigidBody.angularVelocity = Vector3.zero;
        //m_rigidBody.isKinematic = true;
        //transform.SetParent(other.transform);    
    }

}
