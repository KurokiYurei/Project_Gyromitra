using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bramble : MonoBehaviour
{
    [SerializeField]
    private float m_pushPower;

    [SerializeField]
    private float m_pushDuration;
    
    private string m_playerTag;

    // private float m_damage;

    private bool m_playerRecievedDamage;

    private IDamagable m_player;

    void Start()
    {
        m_playerTag = UtilsGyromitra.SearchForTag("Player");

        // m_damage = 25f;

    }

    // Update is called once per frame
    void Update()
    {

    }

    //private void OnCollisionEnter(Collision collision)
    //{

    //    foreach (ContactPoint contact in collision.contacts)
    //    {
    //        Debug.DrawRay(contact.point, contact.normal, Color.white);
    //    }


    //    print("Patatatatatat");
    //    if (collision.collider.CompareTag(m_playerTag))
    //    {
    //        print("Entro");
    //        m_player = collision.collider.GetComponent<IDamagable>();
    //        collision.gameObject.GetComponent<CharacterControllerScript>().SetBounceParameters(collision.contacts[0].normal, m_pushPower, m_pushDuration);
    //        m_playerRecievedDamage = true;

    //    }
    //}

    //private void OnTriggerEnter(Collider other)
    //{
    //    print("Entro");
    //    if (other.tag == m_playerTag)
    //    {

    //        m_player = other.GetComponent<IDamagable>();
    //        m_player.Damage(m_damage);
    //        other.GetComponent<CharacterControllerScript>().
    //        //other.GetComponent<CharacterControllerScript>().SetBounceParameters();
    //        //m_playerRecievedDamage = true;

    //    }
    //}

    //private void OnControllerColliderHit(ControllerColliderHit hit)
    //{
    //    print("Fa controller colider");
    //}

    //private void OnCollisionExit(Collision other)
    //{
    //    if (other.collider.tag == m_playerTag)
    //    {
    //        print("Surto");
    //        m_playerRecievedDamage = false;
    //    }
    //}

    //private void OnTriggerExit(Collider other)
    //{
    //    if (other.tag == m_playerTag)
    //    {
    //        print("Surto");
    //        m_playerRecievedDamage = false;
    //    }
    //}

}
