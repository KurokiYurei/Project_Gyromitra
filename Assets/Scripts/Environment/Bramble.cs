using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bramble : MonoBehaviour
{
    [SerializeField]
    private string m_playerTag;

    private bool m_playerRecievedDamage;

    private IDamagable m_player;

    // Start is called before the first frame update
    void Start()
    {
        m_playerTag = UtilsGyromitra.SearchForTag("Player");
    }

    // Update is called once per frame
    void Update()
    {
        if (!m_playerRecievedDamage && m_player != null)
        {
            m_player.Damage();
        }
    }

    //private void OnCollisionEnter(Collision other)
    //{
    //    if (other.collider.tag == m_playerTag)
    //    {
    //        print("Entro");
    //        m_player = other.collider.GetComponent<IDamagable>();
    //        m_playerRecievedDamage = true;

    //    }
    //}

    private void OnTriggerEnter(Collider other)
    {
        print("Entro");
        if (other.tag == m_playerTag)
        {

            m_player = other.GetComponent<IDamagable>();
            m_playerRecievedDamage = true;

        }
    }

    //private void OnCollisionExit(Collision other)
    //{
    //    if (other.collider.tag == m_playerTag)
    //    {
    //        print("Surto");
    //        m_playerRecievedDamage = false;
    //    }
    //}

    private void OnTriggerExit(Collider other)
    {
        if (other.tag == m_playerTag)
        {
            print("Surto");
            m_playerRecievedDamage = false;
        }
    }

}
