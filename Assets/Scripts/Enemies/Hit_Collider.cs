using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class Hit_Collider : MonoBehaviour
{
    public enum THitColliderType
    {
        BODY = 0,
        HEAD
    }
    public THitColliderType m_ColliderType;

    [SerializeField]
    private Sniper_Behaviour m_enemy;

    [SerializeField]
    private int m_BodyHitAmount;

    [SerializeField]
    private int m_HeadHitAmount;

    public bool m_vulnerable;

    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {

    }
    public void Hit()
    {
        int l_HitAmount = m_HeadHitAmount;
        if (m_ColliderType == THitColliderType.BODY)
            l_HitAmount = m_BodyHitAmount;
        if (m_enemy.m_vulnerable)
            l_HitAmount *= 2;
        m_enemy.GetComponent<Enemy1HP>().Damage(l_HitAmount);
    }

    private void OnCollisionEnter(Collision collision)
    {
        if (collision.transform.tag == "Mushroom")
        {
            gameObject.GetComponentInParent<NavMeshAgent>().enabled = false;
            m_enemy.m_vulnerable = true;
            //SetBounceParameters
            //gameObject.transform.forward *= -1;
            //gameObject.GetComponent<Rigidbody>().AddRelativeForce((gameObject.transform.position - collision.contacts[0].normal) * 3000);
            print("vulnerable");
            collision.transform.GetComponent<Mushroom>().DestroyMushroom();
        }
    }
}
